const activeActions = new Set<string>();

export function acquireAction(key: string) {
  if (activeActions.has(key)) return false;
  activeActions.add(key);
  return true;
}

export function releaseAction(key: string) {
  activeActions.delete(key);
}

export async function withActionLock<T>(key: string, action: () => Promise<T>) {
  if (!acquireAction(key)) throw new Error("Cette action est déjà en cours.");
  try {
    return await action();
  } finally {
    releaseAction(key);
  }
}
