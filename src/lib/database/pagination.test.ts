import { describe, expect, it } from "vitest";
import { normalisePage } from "./pagination";

describe("normalisePage", () => {
  it("bounds untrusted list parameters", () => {
    expect(normalisePage({ page: -2, pageSize: 10_000 })).toEqual({
      page: 1,
      pageSize: 100,
    });
  });
});
