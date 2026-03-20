import { onCall } from "firebase-functions/v2/https";
import { getSecret } from "../config/secrets";

interface AIModelRequest {
  prompt: string;
  model?: string;
  maxTokens?: number;
}

interface AIModelResponse {
  text: string;
  model: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
}

/**
 * Proxies AI model API requests through Cloud Functions.
 *
 * The AI model API key is read from Secret Manager, keeping it
 * off the client device entirely.
 *
 * App Check enforcement is enabled — requests without valid App Check
 * tokens are rejected automatically before the handler runs.
 *
 * Secret Manager keys:
 *   - AI_MODEL_API_KEY
 *
 * Environment variables:
 *   - AI_MODEL_ENDPOINT: The API endpoint URL for the AI model service.
 */
export const aiModelProxy = onCall(
  { enforceAppCheck: true },
  async (request): Promise<AIModelResponse> => {
    const {
      prompt,
      model = "default",
      maxTokens = 1024,
    } = request.data as AIModelRequest;

    if (!prompt || prompt.trim().length === 0) {
      throw new Error("prompt is required and must not be empty");
    }

    const apiKey = await getSecret("AI_MODEL_API_KEY");
    const endpoint = process.env.AI_MODEL_ENDPOINT;

    if (!endpoint) {
      throw new Error(
        "AI_MODEL_ENDPOINT environment variable is not configured"
      );
    }

    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        prompt,
        max_tokens: maxTokens,
      }),
    });

    if (!response.ok) {
      throw new Error(
        `AI model API error: ${response.status} ${response.statusText}`
      );
    }

    const data = (await response.json()) as Record<string, unknown>;

    const choices = data["choices"] as Array<{ text?: string }> | undefined;
    const usageRaw = data["usage"] as
      | {
          prompt_tokens?: number;
          completion_tokens?: number;
          total_tokens?: number;
        }
      | undefined;

    return {
      text: (data["text"] as string) ?? choices?.[0]?.text ?? "",
      model: (data["model"] as string) ?? model,
      usage: usageRaw
        ? {
            promptTokens: usageRaw.prompt_tokens ?? 0,
            completionTokens: usageRaw.completion_tokens ?? 0,
            totalTokens: usageRaw.total_tokens ?? 0,
          }
        : undefined,
    };
  }
);
