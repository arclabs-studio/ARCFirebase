/**
 * In-memory per-UID rate limiter.
 *
 * Scope: per Cloud Function **instance**. Two function instances handle two
 * independent counters. This is acceptable for our volume — bypassing the
 * limiter requires triggering many cold-starts under a single UID, which
 * Firebase already throttles. If we hit real abuse, swap the backing store
 * for Firestore or Memorystore.
 */

interface Bucket {
  count: number;
  windowStartMs: number;
}

const buckets = new Map<string, Bucket>();

/**
 * Returns `true` if the call is allowed, `false` if the UID has exceeded the
 * configured budget within the current window.
 *
 * Window slides per UID: first call starts the window, subsequent calls in
 * the window increment the counter, calls after the window reset the counter.
 *
 * Defaults: 30 calls per 5 minutes per UID.
 */
export function checkRateLimit(
  uid: string,
  maxCalls = 30,
  windowMs = 5 * 60 * 1000
): boolean {
  const now = Date.now();
  const existing = buckets.get(uid);

  if (!existing || now - existing.windowStartMs >= windowMs) {
    buckets.set(uid, { count: 1, windowStartMs: now });
    return true;
  }

  if (existing.count >= maxCalls) {
    return false;
  }

  existing.count += 1;
  return true;
}
