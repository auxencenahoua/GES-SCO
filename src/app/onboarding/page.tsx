import { CheckCircle2, LockKeyhole } from "lucide-react";
import { onboardingSteps } from "@/domain/onboarding/workflow";

export default function OnboardingPage() {
  return (
    <main className="min-h-screen bg-[var(--background)] px-6 py-10 text-[var(--foreground)] sm:px-10">
      <section className="mx-auto max-w-3xl">
        <p className="text-sm font-medium text-[var(--cyan)]">
          GES-SCO · Configuration de l’établissement
        </p>
        <h1 className="mt-3 text-3xl font-semibold tracking-tight">
          Préparer votre espace scolaire
        </h1>
        <p className="mt-3 max-w-2xl leading-7 text-[var(--muted)]">
          Le parcours sera sauvegardé côté serveur et pourra être repris à tout
          moment. L’activation exige les validations de sécurité de la
          plateforme.
        </p>
        <ol className="mt-10 space-y-3" aria-label="Étapes de configuration">
          {onboardingSteps.map((step) => (
            <li
              key={step.key}
              className="flex items-center gap-4 rounded-xl border border-[var(--border)] bg-[var(--surface)] p-4"
            >
              <span className="grid size-8 shrink-0 place-items-center rounded-full bg-[var(--surface-active)] text-sm font-semibold">
                {step.number}
              </span>
              <span className="flex-1 font-medium">{step.label}</span>
              {step.required ? (
                <span className="text-xs text-[var(--muted)]">Obligatoire</span>
              ) : (
                <span className="text-xs text-[var(--muted)]">Optionnelle</span>
              )}
              {step.number === 1 ? (
                <CheckCircle2
                  className="size-5 text-[var(--cyan)]"
                  aria-label="Étape préparée"
                />
              ) : null}
            </li>
          ))}
        </ol>
        <div className="mt-8 flex gap-3 rounded-xl border border-[var(--border)] bg-[var(--surface)] p-5 text-sm leading-6 text-[var(--muted)]">
          <LockKeyhole
            className="mt-0.5 size-5 shrink-0 text-[var(--cyan)]"
            aria-hidden="true"
          />
          <p>
            Fonctionnalité en préparation : l’ouverture d’un établissement sera
            disponible après l’exécution réussie des tests d’isolation
            PostgreSQL.
          </p>
        </div>
      </section>
    </main>
  );
}
