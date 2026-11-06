import { NextRequest, NextResponse } from "next/server";
import { checkRateLimit } from "@/lib/resilience/rate-limit";

export function middleware(request: NextRequest) {
  if (!request.nextUrl.pathname.startsWith("/api/")) return NextResponse.next();
  const visitor =
    request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
    request.headers.get("x-real-ip") ??
    "unknown";
  const result = checkRateLimit(
    `${visitor}:${request.nextUrl.pathname}`,
    60,
    60_000,
  );
  const response = result.allowed
    ? NextResponse.next()
    : NextResponse.json(
        { error: "Trop de requêtes. Réessayez dans quelques instants." },
        { status: 429 },
      );
  response.headers.set("X-RateLimit-Remaining", String(result.remaining));
  if (!result.allowed)
    response.headers.set("Retry-After", String(result.retryAfterSeconds));
  return response;
}

export const config = { matcher: "/api/:path*" };
