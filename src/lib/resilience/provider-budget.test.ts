import { beforeEach, describe, expect, it } from "vitest";
import {
  consumeProviderBudget,
  ProviderBudgetExceededError,
  resetProviderBudgets,
} from "./provider-budget";

describe("provider budget", () => {
  beforeEach(() => resetProviderBudgets());
  it("caps calls and estimated spend", () => {
    const options = {
      provider: "sms",
      maxCalls: 2,
      maxSpendCents: 10,
      estimatedCostCents: 5,
    };
    consumeProviderBudget(options);
    consumeProviderBudget(options);
    expect(() => consumeProviderBudget(options)).toThrow(
      ProviderBudgetExceededError,
    );
  });
});
