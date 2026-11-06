export class UpstreamUnavailableError extends Error {
  constructor() {
    super("Le service distant ne répond pas.");
    this.name = "UpstreamUnavailableError";
  }
}

export async function fetchWithTimeout(
  input: RequestInfo | URL,
  init: RequestInit & { timeoutMs?: number; retries?: number } = {},
) {
  const { timeoutMs = 8_000, retries = 1, ...requestInit } = init;
  for (let attempt = 0; attempt <= retries; attempt += 1) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const response = await fetch(input, {
        ...requestInit,
        signal: controller.signal,
      });
      if (response.ok || attempt === retries || response.status < 500)
        return response;
    } catch (error) {
      if (attempt === retries) throw new UpstreamUnavailableError();
      if (!(error instanceof Error)) throw error;
    } finally {
      clearTimeout(timer);
    }
    await new Promise((resolve) => setTimeout(resolve, 250 * (attempt + 1)));
  }
  throw new UpstreamUnavailableError();
}
