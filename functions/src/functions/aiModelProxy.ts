import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import {
  providerForModel,
  providerConfig,
  mapRequest,
  mapResponse,
  UnifiedRequest,
  UnifiedResponse,
} from "../providers/llmProviders";
import { checkRateLimit } from "../middleware/rateLimit";

const OPENAI_KEY = defineSecret("OPENAI_KEY");
const XAI_KEY = defineSecret("XAI_KEY");

interface AIModelRequest {
  prompt: string;
  model?: string;
  systemPrompt?: string;
  maxTokens?: number;
  temperature?: number;
}

/**
 * Proxies LLM chat-completion requests to OpenAI or xAI/Grok.
 *
 * The provider is resolved from the `model` field (e.g. `gpt-4o-mini` → OpenAI,
 * `grok-4-1-fast` → xAI). Provider API keys live in Firebase Secret Manager —
 * declared via `defineSecret(...)` and never reach the device.
 *
 * Security stack:
 *   1. App Check (enforced by Firebase runtime before the handler runs).
 *   2. Firebase Auth — handler rejects unauthenticated callers.
 *   3. Per-UID rate limit — soft cap to bound runaway cost from a single account.
 *
 * Secrets:
 *   - OPENAI_KEY (set via: `firebase functions:secrets:set OPENAI_KEY`)
 *   - XAI_KEY    (set via: `firebase functions:secrets:set XAI_KEY`)
 */
export const aiModelProxy = onCall(
  { secrets: [OPENAI_KEY, XAI_KEY], enforceAppCheck: true },
  async (request): Promise<UnifiedResponse> => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Sign-in required to call aiModelProxy."
      );
    }

    if (!checkRateLimit(uid)) {
      throw new HttpsError(
        "resource-exhausted",
        "Rate limit exceeded. Try again later."
      );
    }

    const data = request.data as AIModelRequest;
    const prompt = data?.prompt;
    if (!prompt || prompt.trim().length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "`prompt` is required and must not be empty."
      );
    }

    const model = data.model ?? "gpt-4o-mini";

    let provider: ReturnType<typeof providerForModel>;
    try {
      provider = providerForModel(model);
    } catch {
      throw new HttpsError("invalid-argument", `Unsupported model: ${model}`);
    }

    const apiKey = provider === "openai" ? OPENAI_KEY.value() : XAI_KEY.value();
    const { baseUrl, authHeaders } = providerConfig(provider);

    const unified: UnifiedRequest = {
      prompt,
      model,
      systemPrompt: data.systemPrompt,
      maxTokens: data.maxTokens,
      temperature: data.temperature,
    };

    let response: Response;
    try {
      response = await fetch(baseUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          ...authHeaders(apiKey),
        },
        body: JSON.stringify(mapRequest(unified)),
      });
    } catch (err) {
      // Network-level failure — do not leak the inner message; it may
      // include host/IP details from the underlying http stack.
      throw new HttpsError(
        "unavailable",
        `Upstream provider request failed (${provider}).`
      );
    }

    if (!response.ok) {
      // Read provider error text but DO NOT echo it to the client — it may
      // include account hints. Log server-side via Firebase logs only.
      const errBody = await response.text().catch(() => "<unreadable>");
      console.error(
        `[aiModelProxy] provider=${provider} status=${response.status} body=${errBody.slice(0, 500)}`
      );
      throw new HttpsError(
        "internal",
        `Provider returned ${response.status}.`
      );
    }

    const raw = (await response.json()) as Record<string, unknown>;
    return mapResponse(raw, model);
  }
);
