import { describe, expect, it } from "vitest";
import { checkRateLimit } from "./rate-limit";

describe("checkRateLimit", () => {
  it("rejects requests over the configured limit", () => {
    const key = `visitor-${crypto.randomUUID()}`;
    expect(checkRateLimit(key, 2).allowed).toBe(true);
    expect(checkRateLimit(key, 2).allowed).toBe(true);
    expect(checkRateLimit(key, 2).allowed).toBe(false);
  });
});
