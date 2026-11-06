import { describe, expect, it } from "vitest";
import {
  completeStep,
  markReadyForActivation,
  OnboardingTransitionError,
  skipStep,
  type OnboardingDraft,
} from "./workflow";

const draft: OnboardingDraft = {
  currentStep: 1,
  completedSteps: [],
  status: "in_progress",
  version: 1,
};

describe("onboarding workflow", () => {
  it("requires steps to be completed in order", () => {
    expect(() => completeStep(draft, 2)).toThrow(OnboardingTransitionError);
  });

  it("permits optional data import to be skipped", () => {
    const atImport = {
      ...draft,
      currentStep: 6 as const,
      completedSteps: [1, 2, 3, 4, 5] as const,
    };
    expect(skipStep(atImport, 6).currentStep).toBe(7);
  });

  it("rejects skipping required steps", () => {
    expect(() => skipStep(draft, 1)).toThrow(OnboardingTransitionError);
  });

  it("allows activation only when all required steps are complete", () => {
    expect(() => markReadyForActivation(draft)).toThrow(
      OnboardingTransitionError,
    );
    const ready = markReadyForActivation({
      ...draft,
      completedSteps: [1, 2, 3, 5, 8],
    });
    expect(ready.status).toBe("ready_for_activation");
  });
});
