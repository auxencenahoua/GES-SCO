import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { Pool, type PoolClient } from "pg";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

const databaseUrl = process.env.DATABASE_TEST_URL;
const integrationTest = databaseUrl ? describe : describe.skip;

const tenantA = "11111111-1111-4111-8111-111111111111";
const tenantB = "22222222-2222-4222-8222-222222222222";
let database: Pool;

async function asApplication<T>(
  tenantId: string | undefined,
  work: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const client = await database.connect();
  try {
    await client.query("BEGIN");
    await client.query("SET LOCAL ROLE ges_sco_test_app");
    if (tenantId) {
      await client.query("SELECT set_config('app.tenant_id', $1, true)", [
        tenantId,
      ]);
    }
    const result = await work(client);
    await client.query("ROLLBACK");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

integrationTest("PostgreSQL RLS tenant isolation", () => {
  beforeAll(async () => {
    database = new Pool({ connectionString: databaseUrl });
    const migrations = await Promise.all(
      [
        "0001_identity_and_tenants.sql",
        "0002_onboarding.sql",
        "0003_academic_core.sql",
        "0004_pedagogy.sql",
        "0005_finance_and_audit.sql",
        "0006_supporting_modules.sql",
        "0007_performance_indexes.sql",
      ].map((file) =>
        readFile(join(process.cwd(), "database", "migrations", file), "utf8"),
      ),
    );

    await database.query("DROP SCHEMA IF EXISTS app CASCADE");
    await database.query("DROP SCHEMA IF EXISTS auth CASCADE");
    await database.query("DROP ROLE IF EXISTS ges_sco_test_app");
    await database.query("CREATE SCHEMA auth");
    await database.query('CREATE TABLE auth."user" (id text PRIMARY KEY)');
    for (const migration of migrations) await database.query(migration);
    await database.query("CREATE ROLE ges_sco_test_app NOINHERIT");
    await database.query("GRANT USAGE ON SCHEMA app TO ges_sco_test_app");
    await database.query(
      "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO ges_sco_test_app",
    );
    await database.query(
      "INSERT INTO app.tenant (id, legal_name, display_name, status) VALUES ($1, 'Établissement A', 'École A', 'active'), ($2, 'Établissement B', 'École B', 'active')",
      [tenantA, tenantB],
    );
  });

  afterAll(async () => {
    await database.end();
  });

  it("refuses every tenant when no tenant context is set", async () => {
    const rows = await asApplication(undefined, (client) =>
      client.query("SELECT id FROM app.tenant"),
    );
    expect(rows.rows).toEqual([]);
  });

  it("reads only the transaction tenant", async () => {
    const rows = await asApplication(tenantA, (client) =>
      client.query("SELECT id FROM app.tenant ORDER BY id"),
    );
    expect(rows.rows).toEqual([{ id: tenantA }]);
  });

  it("cannot update another tenant's data", async () => {
    const result = await asApplication(tenantA, (client) =>
      client.query(
        "UPDATE app.tenant SET display_name = 'Compromis' WHERE id = $1 RETURNING id",
        [tenantB],
      ),
    );
    expect(result.rowCount).toBe(0);
  });

  it("keeps academic records isolated across establishments", async () => {
    await asApplication(tenantA, (client) =>
      client.query(
        "INSERT INTO app.subject (tenant_id, code, name) VALUES ($1, 'MATH', 'Mathématiques')",
        [tenantA],
      ),
    );
    const rows = await asApplication(tenantB, (client) =>
      client.query("SELECT code FROM app.subject"),
    );
    expect(rows.rows).toEqual([]);
  });
});
