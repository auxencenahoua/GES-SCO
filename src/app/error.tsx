"use client";

import { useEffect } from "react";
import { reportError } from "@/lib/observability/report-error";

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    reportError(error, { digest: error.digest, boundary: "app" });
  }, [error]);
  return (
    <main className="grid min-h-screen place-items-center bg-[var(--background)] p-6 text-[var(--foreground)]">
      <section className="max-w-md rounded-xl border border-[var(--border)] bg-[var(--surface)] p-7">
        <p className="text-sm font-medium text-[var(--danger)]">
          Une erreur est survenue
        </p>
        <h1 className="mt-2 text-2xl font-semibold">
          La page n’a pas pu être chargée.
        </h1>
        <p className="mt-3 leading-7 text-[var(--muted)]">
          Réessayez. Si le problème persiste, communiquez l’heure de l’incident
          au support.
        </p>
        <button
          type="button"
          onClick={reset}
          className="mt-6 min-h-11 rounded-lg bg-[var(--primary)] px-4 text-sm font-medium text-white"
        >
          Réessayer
        </button>
      </section>
    </main>
  );
}
