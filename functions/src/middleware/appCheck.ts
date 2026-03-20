import { HttpsError } from "firebase-functions/v2/https";

/**
 * Verifies that a request includes a valid App Check token.
 *
 * When using `onCall({ enforceAppCheck: true }, ...)`, Firebase Functions v2
 * automatically rejects requests without valid App Check tokens before the
 * handler is called. Use this helper for manual verification in edge cases
 * where you need more control over the error response.
 *
 * @param appCheckToken - The App Check token from the request context.
 */
export async function verifyAppCheck(
  appCheckToken: string | undefined
): Promise<void> {
  if (!appCheckToken) {
    throw new HttpsError(
      "unauthenticated",
      "App Check token is missing. Requests must include a valid App Check token."
    );
  }
}
