import { ArrowUpRight, Building2, ShieldCheck, Users } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

const foundations = [
  {
    title: "Isolation des établissements",
    description:
      "Tenant, adhésions, politiques d’accès et isolation base de données seront vérifiés avant les modules métier.",
    icon: Building2,
  },
  {
    title: "Accès à privilèges minimaux",
    description:
      "Les rôles et permissions seront évalués côté serveur pour chaque action sensible.",
    icon: ShieldCheck,
  },
  {
    title: "Expérience adaptée aux écoles",
    description:
      "Français et XOF constituent la configuration de lancement pour les établissements ivoiriens.",
    icon: Users,
  },
];

export default function Home() {
  return (
    <main className="min-h-screen bg-[var(--background)] px-6 py-10 text-[var(--foreground)] sm:px-10 lg:px-16">
      <div className="mx-auto max-w-6xl">
        <header className="flex items-center justify-between border-b border-[var(--border)] pb-8">
          <div className="flex items-center gap-3">
            <div className="grid size-10 place-items-center rounded-xl bg-[var(--primary)] font-bold text-white">
              G
            </div>
            <div>
              <p className="text-lg font-semibold tracking-tight">GES-SCO</p>
              <p className="text-sm text-[var(--muted)]">Fondations produit</p>
            </div>
          </div>
          <Badge>Phase 1</Badge>
        </header>

        <section className="grid gap-10 py-20 lg:grid-cols-[1.3fr_0.7fr] lg:items-end">
          <div>
            <p className="mb-4 text-sm font-medium text-[var(--cyan)]">
              Gestion scolaire SaaS · Côte d’Ivoire
            </p>
            <h1 className="max-w-3xl text-4xl font-semibold tracking-tight sm:text-6xl">
              Une base fiable avant chaque opération scolaire.
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-8 text-[var(--muted)]">
              GES-SCO est construit par phases : sécurité, séparation des
              établissements et contrôle des accès précèdent les dossiers
              élèves, notes et paiements.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Button
                disabled
                title="Disponible après l’implémentation de l’identité"
              >
                Créer un établissement <ArrowUpRight aria-hidden="true" />
              </Button>
              <Button
                variant="secondary"
                disabled
                title="Disponible après l’implémentation de l’identité"
              >
                Se connecter
              </Button>
            </div>
          </div>
          <aside className="rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-6 shadow-[0_16px_50px_rgba(0,0,0,0.2)]">
            <p className="text-sm text-[var(--muted)]">État du produit</p>
            <p className="mt-2 text-2xl font-semibold">Fondations en cours</p>
            <p className="mt-4 text-sm leading-6 text-[var(--muted)]">
              Les actions visibles sont volontairement indisponibles jusqu’à la
              livraison et aux tests de l’identité multi-tenant.
            </p>
          </aside>
        </section>

        <section aria-labelledby="foundations-title" className="pb-12">
          <h2 id="foundations-title" className="text-2xl font-semibold">
            Fondations non négociables
          </h2>
          <div className="mt-6 grid gap-4 md:grid-cols-3">
            {foundations.map(({ title, description, icon: Icon }) => (
              <article
                key={title}
                className="rounded-xl border border-[var(--border)] bg-[var(--surface)] p-6"
              >
                <Icon
                  className="size-5 text-[var(--cyan)]"
                  aria-hidden="true"
                />
                <h3 className="mt-5 font-semibold">{title}</h3>
                <p className="mt-2 text-sm leading-6 text-[var(--muted)]">
                  {description}
                </p>
              </article>
            ))}
          </div>
        </section>
      </div>
    </main>
  );
}
