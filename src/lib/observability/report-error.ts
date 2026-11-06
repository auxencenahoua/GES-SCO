export function reportError(
  error: unknown,
  context: Record<string, unknown> = {},
) {
  const payload = {
    name: error instanceof Error ? error.name : "UnknownError",
    message: error instanceof Error ? error.message : String(error),
    ...context,
    timestamp: new Date().toISOString(),
  };
  console.error("GES-SCO error", payload);
  return payload;
}
