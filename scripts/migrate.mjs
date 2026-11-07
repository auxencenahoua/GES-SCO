import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";

const connectionString =
  process.env.DATABASE_URL_UNPOOLED ?? process.env.DATABASE_URL;
if (!connectionString)
  throw new Error("DATABASE_URL_UNPOOLED (or DATABASE_URL) is required");

const root = fileURLToPath(new URL("..", import.meta.url));
const migrationsDir = join(root, "database", "migrations");
const pool = new pg.Pool({ connectionString, max: 1 });

try {
  await pool.query("SELECT pg_advisory_lock(420271)");
  await pool.query(
    "CREATE TABLE IF NOT EXISTS public.schema_migrations (version text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())",
  );
  // The application auth adapter owns the complete auth schema. This stable
  // identity table is created first so tenant FKs can be applied on a fresh
  // preview database before Better Auth performs its own schema synchronization.
  await pool.query("CREATE SCHEMA IF NOT EXISTS auth");
  await pool.query(
    'CREATE TABLE IF NOT EXISTS auth."user" (id text PRIMARY KEY)',
  );
  const applied = new Set(
    (await pool.query("SELECT version FROM public.schema_migrations")).rows.map(
      (row) => row.version,
    ),
  );
  const files = (await readdir(migrationsDir))
    .filter((file) => /^\d+_.+\.sql$/.test(file))
    .sort();
  for (const file of files) {
    if (applied.has(file)) continue;
    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      await client.query(await readFile(join(migrationsDir, file), "utf8"));
      await client.query(
        "INSERT INTO public.schema_migrations (version) VALUES ($1)",
        [file],
      );
      await client.query("COMMIT");
      console.log(`Applied ${file}`);
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }
  console.log("Database is up to date");
} finally {
  await pool.query("SELECT pg_advisory_unlock(420271)").catch(() => undefined);
  await pool.end();
}
