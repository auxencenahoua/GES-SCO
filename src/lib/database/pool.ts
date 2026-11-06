import { Pool, type PoolClient } from "pg";

declare global {
  // eslint-disable-next-line no-var
  var gesScoPool: Pool | undefined;
}

export function getDatabasePool(): Pool {
  if (globalThis.gesScoPool) return globalThis.gesScoPool;

  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("DATABASE_URL doit être défini côté serveur.");
  }

  globalThis.gesScoPool = new Pool({
    connectionString,
    max: 10,
    application_name: "ges-sco-web",
  });
  return globalThis.gesScoPool;
}

/**
 * Runs business queries under a transaction-scoped tenant context.
 * PostgreSQL RLS is the enforcement layer; callers must never inject a tenant
 * id from the browser into this function.
 */
export async function withTenantTransaction<T>(
  tenantId: string,
  work: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const client = await getDatabasePool().connect();
  try {
    await client.query("BEGIN");
    await client.query("SELECT set_config('app.tenant_id', $1, true)", [
      tenantId,
    ]);
    const result = await work(client);
    await client.query("COMMIT");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}
