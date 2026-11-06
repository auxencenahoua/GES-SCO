import Link from "next/link";
import {
  ArrowRight,
  Building2,
  CalendarDays,
  CircleAlert,
  ShieldCheck,
  Users,
} from "lucide-react";

const actions = [
  [
    "Configurer l’établissement",
    "Finaliser les préférences, campus et année scolaire.",
    "/onboarding",
    Building2,
  ],
  [
    "Gérer les élèves",
    "Créer les dossiers, responsables et inscriptions.",
    "/app/scolarite",
    Users,
  ],
  [
    "Préparer l’année",
    "Configurer classes, matières et emploi du temps.",
    "/app/pedagogie",
    CalendarDays,
  ],
] as const;

export default function ApplicationHome() {
  return (
    <main className="min-h-screen bg-[var(--background)] px-6 py-10 text-[var(--foreground)] sm:px-10">
      <section className="mx-auto max-w-6xl">
        <header className="flex flex-wrap items-start justify-between gap-4 border-b border-[var(--border)] pb-8">
          <div>
            <p className="text-sm font-medium text-[var(--cyan)]">
              GES-SCO · Espace établissement
            </p>
            <h1 className="mt-2 text-3xl font-semibold tracking-tight">
              Tableau de bord
            </h1>
            <p className="mt-2 max-w-2xl leading-7 text-[var(--muted)]">
              Pilotez les opérations de votre établissement depuis un espace
              isolé et sécurisé.
            </p>
          </div>
          <Link
            href="/onboarding"
            className="inline-flex min-h-11 items-center gap-2 rounded-lg bg-[var(--primary)] px-4 text-sm font-medium text-white hover:brightness-110"
          >
            Reprendre la configuration{" "}
            <ArrowRight className="size-4" aria-hidden="true" />
          </Link>
        </header>

        <div className="mt-8 grid gap-4 md:grid-cols-3">
          {[
            [
              "Élèves actifs",
              "—",
              "Les données seront affichées après connexion à la base.",
            ],
            ["Factures à suivre", "—", "Aucune donnée financière chargée."],
            ["Présences aujourd’hui", "—", "Aucun appel saisi pour le moment."],
          ].map(([label, value, description]) => (
            <article
              key={label}
              className="rounded-xl border border-[var(--border)] bg-[var(--surface)] p-5"
            >
              <p className="text-sm text-[var(--muted)]">{label}</p>
              <p className="mt-3 text-3xl font-semibold">{value}</p>
              <p className="mt-3 text-sm leading-6 text-[var(--muted)]">
                {description}
              </p>
            </article>
          ))}
        </div>

        <section className="mt-10" aria-labelledby="actions-title">
          <h2 id="actions-title" className="text-xl font-semibold">
            Démarrer
          </h2>
          <div className="mt-4 grid gap-4 lg:grid-cols-3">
            {actions.map(([title, description, href, Icon]) => (
              <Link
                key={title}
                href={href}
                className="group rounded-xl border border-[var(--border)] bg-[var(--surface)] p-5 transition-colors hover:border-[var(--primary)]"
              >
                <Icon
                  className="size-5 text-[var(--cyan)]"
                  aria-hidden="true"
                />
                <h3 className="mt-4 font-semibold">{title}</h3>
                <p className="mt-2 text-sm leading-6 text-[var(--muted)]">
                  {description}
                </p>
                <span className="mt-4 inline-flex items-center gap-1 text-sm text-[var(--cyan)]">
                  Ouvrir{" "}
                  <ArrowRight
                    className="size-4 transition-transform group-hover:translate-x-1"
                    aria-hidden="true"
                  />
                </span>
              </Link>
            ))}
          </div>
        </section>

        <aside className="mt-10 flex gap-3 rounded-xl border border-[var(--border)] bg-[var(--surface)] p-5 text-sm leading-6 text-[var(--muted)]">
          <ShieldCheck
            className="mt-0.5 size-5 shrink-0 text-[var(--cyan)]"
            aria-hidden="true"
          />
          <p>
            Les données affichées ici proviendront exclusivement de la session
            et du tenant validés côté serveur. Les métriques restent vides tant
            que PostgreSQL et l’authentification ne sont pas configurés.
          </p>
        </aside>
        <aside className="mt-4 flex gap-3 rounded-xl border border-[var(--border)] bg-[var(--surface)] p-5 text-sm leading-6 text-[var(--muted)]">
          <CircleAlert
            className="mt-0.5 size-5 shrink-0 text-[var(--warning)]"
            aria-hidden="true"
          />
          <p>
            Les intégrations de paiement, messagerie et stockage doivent être
            configurées avant toute opération réelle.
          </p>
        </aside>
      </section>
    </main>
  );
}
