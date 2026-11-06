import { NextResponse } from "next/server";
import { getDatabasePool } from "@/lib/database/pool";

export const dynamic = "force-dynamic";

export async function GET() {
  const startedAt = Date.now();
  try {
    await Promise.race([
      getDatabasePool().query("SELECT 1"),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error("database timeout")), 2_000),
      ),
    ]);
    return NextResponse.json(
      { status: "ok", database: "ok", durationMs: Date.now() - startedAt },
      { headers: { "Cache-Control": "no-store" } },
    );
  } catch {
    return NextResponse.json(
      { status: "degraded", database: "unavailable" },
      { status: 503, headers: { "Cache-Control": "no-store" } },
    );
  }
}
