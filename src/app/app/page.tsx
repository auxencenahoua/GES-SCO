import Link from "next/link";
import {
  BookOpen,
  ClipboardCheck,
  FileText,
  GraduationCap,
  Landmark,
  Megaphone,
  Package,
  UtensilsCrossed,
  Users,
} from "lucide-react";

const modules = [
  [
    "Scolarité",
    "Élèves, familles, personnel, classes et inscriptions",
    "/app/scolarite",
    Users,
  ],
  [
    "Pédagogie",
    "Emplois du temps, présences, évaluations et bulletins",
    "/app/pedagogie",
    GraduationCap,
  ],
  [
    "Finance",
    "Frais, factures, paiements, reçus et remboursements",
    "/app/finance",
    Landmark,
  ],
  [
    "Communication",
    "Annonces, notifications et préférences",
    "/app/communication",
    Megaphone,
  ],
  [
    "Documents",
    "Modèles, fichiers privés et exports",
    "/app/documents",
    FileText,
  ],
  [
    "E-learning",
    "Cours, devoirs, rendus et progression",
    "/app/elearning",
    ClipboardCheck,
  ],
  [
    "Bibliothèque",
    "Catalogue, exemplaires et prêts",
    "/app/bibliotheque",
    BookOpen,
  ],
  [
    "Cantine & inventaire",
    "Menus, services et stock",
    "/app/services",
    UtensilsCrossed,
  ],
  ["RH & rapports", "Absences, pilotage et exports", "/app/rapports", Package],
] as const;

export default function ApplicationHome() {
  return (
    <main className="min-h-screen bg-[var(--background)] px-6 py-10 text-[var(--foreground)] sm:px-10">
      <section className="mx-auto max-w-6xl">
        <p className="text-sm font-medium text-[var(--cyan)]">
          GES-SCO · Espace établissement
        </p>
        <h1 className="mt-3 text-3xl font-semibold tracking-tight">
          Opérations scolaires
        </h1>
        <p className="mt-3 max-w-2xl leading-7 text-[var(--muted)]">
          Les modules s’ouvrent après authentification, appartenance active et
          contrôle serveur des permissions. Cette prévisualisation ne charge
          aucune donnée établissement.
        </p>
        <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {modules.map(([name, description, href, Icon]) => (
            <Link
              key={name}
              href={href}
              className="rounded-xl border border-[var(--border)] bg-[var(--surface)] p-6 transition-colors hover:border-[var(--primary)] focus-visible:outline-none"
            >
              <Icon className="size-5 text-[var(--cyan)]" aria-hidden="true" />
              <h2 className="mt-4 font-semibold">{name}</h2>
              <p className="mt-2 text-sm leading-6 text-[var(--muted)]">
                {description}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </main>
  );
}
