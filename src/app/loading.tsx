export default function Loading() {
  return (
    <main className="min-h-screen bg-[var(--background)] p-10 text-[var(--foreground)]">
      <div className="mx-auto max-w-6xl animate-pulse space-y-5">
        <div className="h-6 w-40 rounded bg-[var(--surface-active)]" />
        <div className="h-12 w-80 rounded bg-[var(--surface-active)]" />
        <div className="grid gap-4 md:grid-cols-3">
          {Array.from({ length: 3 }, (_, index) => (
            <div key={index} className="h-40 rounded-xl bg-[var(--surface)]" />
          ))}
        </div>
      </div>
    </main>
  );
}
