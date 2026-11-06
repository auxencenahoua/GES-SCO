import Link from "next/link";
import { notFound } from "next/navigation";

const labels: Record<string, string> = {
  scolarite: "Scolarité",
  pedagogie: "Pédagogie",
  finance: "Finance",
  communication: "Communication",
  documents: "Documents",
  elearning: "E-learning",
  bibliotheque: "Bibliothèque",
  services: "Cantine & inventaire",
  rapports: "RH & rapports",
};

export default async function ModulePage({
  params,
}: {
  params: Promise<{ module: string }>;
}) {
  const { module } = await params;
  const label = labels[module];
  if (!label) notFound();
  return (
    <main className="min-h-screen bg-[var(--background)] px-6 py-10 text-[var(--foreground)] sm:px-10">
      <section className="mx-auto max-w-3xl rounded-2xl border border-[var(--border)] bg-[var(--surface)] p-8">
        <Link href="/app" className="text-sm text-[var(--cyan)]">
          ← Tous les modules
        </Link>
        <h1 className="mt-6 text-3xl font-semibold">{label}</h1>
        <p className="mt-4 leading-7 text-[var(--muted)]">
          Le domaine est modélisé, isolé par établissement et prêt à recevoir
          ses parcours transactionnels. Pour afficher ou modifier des données
          réelles, configurez PostgreSQL, Better Auth, les invitations et le
          contrôle d’accès serveur.
        </p>
      </section>
    </main>
  );
}
