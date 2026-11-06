import { describe, expect, it, beforeEach } from "vitest";
import { clearMemoized, memoizeFor } from "./cache";

describe("memoizeFor", () => {
  beforeEach(() => clearMemoized());
  it("reuses values during the TTL", () => {
    let calls = 0;
    expect(memoizeFor("x", 1000, () => ++calls)).toBe(1);
    expect(memoizeFor("x", 1000, () => ++calls)).toBe(1);
    expect(calls).toBe(1);
  });
});
