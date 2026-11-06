import { describe, expect, it } from "vitest";
import { formatXof } from "./money";

describe("formatXof", () => {
  it("formats a whole XOF amount", () => {
    expect(formatXof(12500)).toContain("12");
  });

  it("rejects a floating point amount", () => {
    expect(() => formatXof(12.5)).toThrow("entier sûr");
  });
});
