type Entry<T> = { value: T; expiresAt: number };

const entries = new Map<string, Entry<unknown>>();

export function memoizeFor<T>(key: string, ttlMs: number, factory: () => T): T {
  const now = Date.now();
  const existing = entries.get(key) as Entry<T> | undefined;
  if (existing && existing.expiresAt > now) return existing.value;
  const value = factory();
  entries.set(key, { value, expiresAt: now + Math.max(0, ttlMs) });
  return value;
}

export function clearMemoized(key?: string) {
  if (key) entries.delete(key);
  else entries.clear();
}
