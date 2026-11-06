type Budget = { calls: number; windowStartedAt: number; spentCents: number };

const budgets = new Map<string, Budget>();

export class ProviderBudgetExceededError extends Error {
  constructor(message = "Le quota de ce service est temporairement atteint.") {
    super(message);
    this.name = "ProviderBudgetExceededError";
  }
}

export function consumeProviderBudget(options: {
  provider: string;
  maxCalls: number;
  maxSpendCents: number;
  estimatedCostCents?: number;
  windowMs?: number;
}) {
  const now = Date.now();
  const windowMs = options.windowMs ?? 60 * 60 * 1000;
  const current = budgets.get(options.provider);
  const budget =
    !current || now - current.windowStartedAt >= windowMs
      ? { calls: 0, windowStartedAt: now, spentCents: 0 }
      : current;
  const cost = Math.max(0, options.estimatedCostCents ?? 0);
  if (
    budget.calls >= options.maxCalls ||
    budget.spentCents + cost > options.maxSpendCents
  ) {
    throw new ProviderBudgetExceededError();
  }
  budget.calls += 1;
  budget.spentCents += cost;
  budgets.set(options.provider, budget);
  return {
    remainingCalls: options.maxCalls - budget.calls,
    remainingCents: options.maxSpendCents - budget.spentCents,
  };
}

export function resetProviderBudgets() {
  budgets.clear();
}
