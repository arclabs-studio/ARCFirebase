/**
 * LLM provider routing and request/response shaping.
 *
 * Each provider (OpenAI, xAI/Grok) exposes a chat-completions style HTTP API.
 * This module isolates the per-provider differences (base URL, model prefix,
 * which secret to use) so `aiModelProxy.ts` stays a thin orchestration layer.
 *
 * Adding a new provider (e.g. Anthropic) is: add a new `LLMProvider` value,
 * a config entry, a `providerForModel` rule, and — if the provider's HTTP
 * schema differs from chat-completions — an adapter in `mapRequest` /
 * `mapResponse`.
 */

export type LLMProvider = "openai" | "grok";

export interface UnifiedRequest {
  prompt: string;
  model: string;
  systemPrompt?: string;
  maxTokens?: number;
  temperature?: number;
}

export interface UnifiedResponse {
  text: string;
  model: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
}

interface ProviderConfig {
  baseUrl: string;
  authHeaders: (apiKey: string) => Record<string, string>;
}

const PROVIDER_CONFIG: Record<LLMProvider, ProviderConfig> = {
  openai: {
    baseUrl: "https://api.openai.com/v1/chat/completions",
    authHeaders: (apiKey) => ({ Authorization: `Bearer ${apiKey}` }),
  },
  grok: {
    // xAI exposes an OpenAI-compatible chat completions endpoint.
    baseUrl: "https://api.x.ai/v1/chat/completions",
    authHeaders: (apiKey) => ({ Authorization: `Bearer ${apiKey}` }),
  },
};

/**
 * Resolves an LLM provider from a model string.
 *
 * - `gpt-*` → openai
 * - `grok-*` → grok
 *
 * Throws if the model prefix is unknown — proxy must not silently fall back
 * to a different provider with a different billing account.
 */
export function providerForModel(model: string): LLMProvider {
  const m = model.toLowerCase();
  if (m.startsWith("gpt-")) return "openai";
  if (m.startsWith("grok-")) return "grok";
  throw new Error(`Unsupported model: ${model}`);
}

export function providerConfig(provider: LLMProvider): ProviderConfig {
  return PROVIDER_CONFIG[provider];
}

/**
 * Builds a chat-completions style request body from the unified request shape.
 * Both OpenAI and xAI/Grok accept this schema.
 */
export function mapRequest(req: UnifiedRequest): Record<string, unknown> {
  const messages: Array<{ role: string; content: string }> = [];
  if (req.systemPrompt && req.systemPrompt.trim().length > 0) {
    messages.push({ role: "system", content: req.systemPrompt });
  }
  messages.push({ role: "user", content: req.prompt });

  const body: Record<string, unknown> = {
    model: req.model,
    messages,
  };
  if (req.maxTokens !== undefined) body["max_tokens"] = req.maxTokens;
  if (req.temperature !== undefined) body["temperature"] = req.temperature;
  return body;
}

/**
 * Normalizes a chat-completions response into the unified shape consumed by
 * the iOS app (`AIProxyResponse`).
 */
export function mapResponse(
  raw: Record<string, unknown>,
  fallbackModel: string
): UnifiedResponse {
  const choices = raw["choices"] as
    | Array<{ message?: { content?: string }; text?: string }>
    | undefined;
  const text =
    choices?.[0]?.message?.content ?? choices?.[0]?.text ?? "";

  const usageRaw = raw["usage"] as
    | {
        prompt_tokens?: number;
        completion_tokens?: number;
        total_tokens?: number;
      }
    | undefined;

  return {
    text,
    model: (raw["model"] as string) ?? fallbackModel,
    usage: usageRaw
      ? {
          promptTokens: usageRaw.prompt_tokens ?? 0,
          completionTokens: usageRaw.completion_tokens ?? 0,
          totalTokens: usageRaw.total_tokens ?? 0,
        }
      : undefined,
  };
}
