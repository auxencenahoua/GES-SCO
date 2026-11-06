type Bucket = { count: number; resetsAt: number };
const buckets = new Map<string, Bucket>();

/** Process-local protection. Use Redis/Upstash in multi-instance production. */
export function checkRateLimit(key: string, limit = 60, windowMs = 60_000) {
  const now = Date.now();
  const bucket = buckets.get(key);
  if (!bucket || bucket.resetsAt <= now) {
    buckets.set(key, { count: 1, resetsAt: now + windowMs });
    return { allowed: true, remaining: limit - 1, retryAfterSeconds: 0 };
  }
  bucket.count += 1;
  return {
    allowed: bucket.count <= limit,
    remaining: Math.max(0, limit - bucket.count),
    retryAfterSeconds: Math.ceil((bucket.resetsAt - now) / 1_000),
  };
}
