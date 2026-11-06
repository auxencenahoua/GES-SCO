export const onboardingSteps = [
  { number: 1, key: "owner", label: "Compte propriétaire", required: true },
  { number: 2, key: "school", label: "Établissement", required: true },
  { number: 3, key: "preferences", label: "Préférences", required: true },
  {
    number: 4,
    key: "academic",
    label: "Configuration académique",
    required: false,
  },
  { number: 5, key: "modules", label: "Modules", required: true },
  { number: 6, key: "import", label: "Import des données", required: false },
  { number: 7, key: "members", label: "Utilisateurs", required: false },
  { number: 8, key: "review", label: "Vérification", required: true },
] as const;

export type OnboardingStep = (typeof onboardingSteps)[number]["number"];
export type OnboardingStatus =
  | "in_progress"
  | "ready_for_activation"
  | "activated"
  | "cancelled";

export type OnboardingDraft = {
  currentStep: OnboardingStep;
  completedSteps: readonly OnboardingStep[];
  status: OnboardingStatus;
  version: number;
};

export function completeStep(
  draft: OnboardingDraft,
  step: OnboardingStep,
): OnboardingDraft {
  if (draft.status !== "in_progress")
    throw new OnboardingTransitionError(
      "Ce brouillon ne peut plus être modifié.",
    );
  if (step !== draft.currentStep)
    throw new OnboardingTransitionError(
      "Une étape doit être terminée dans l’ordre.",
    );

  const completedSteps = [...new Set([...draft.completedSteps, step])].sort(
    (a, b) => a - b,
  ) as OnboardingStep[];
  const nextStep = Math.min(step + 1, 8) as OnboardingStep;
  return {
    ...draft,
    completedSteps,
    currentStep: nextStep,
    version: draft.version + 1,
  };
}

export function skipStep(
  draft: OnboardingDraft,
  step: OnboardingStep,
): OnboardingDraft {
  const definition = onboardingSteps.find(
    (candidate) => candidate.number === step,
  );
  if (!definition || definition.required)
    throw new OnboardingTransitionError(
      "Cette étape est obligatoire et ne peut pas être ignorée.",
    );
  return completeStep(draft, step);
}

export function markReadyForActivation(
  draft: OnboardingDraft,
): OnboardingDraft {
  const requiredSteps = onboardingSteps
    .filter((step) => step.required)
    .map((step) => step.number);
  if (
    !requiredSteps.every((step) =>
      draft.completedSteps.includes(step as OnboardingStep),
    )
  ) {
    throw new OnboardingTransitionError(
      "Les étapes obligatoires doivent être terminées avant activation.",
    );
  }
  return {
    ...draft,
    status: "ready_for_activation",
    version: draft.version + 1,
  };
}

export class OnboardingTransitionError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "OnboardingTransitionError";
  }
}
