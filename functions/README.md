# ARCFirebase Cloud Functions

Server-side proxies that keep real provider keys off the device. Every function
enforces Firebase App Check; functions that touch real money also require an
authenticated Firebase user.

## Deployed functions

| Function | Provider routed | Secrets consumed | Auth required |
|---|---|---|---|
| `aiModelProxy` | OpenAI (`gpt-*`), xAI/Grok (`grok-*`) | `OPENAI_KEY`, `XAI_KEY` | Yes (Firebase Auth UID) |
| `googlePlacesProxy` | Google Places API (New) | `GOOGLE_PLACES_API_KEY` | No (App Check only) |
| `deviceCheckValidation` | Apple DeviceCheck | `DEVICECHECK_PRIVATE_KEY`, `DEVICECHECK_KEY_ID`, `DEVICECHECK_TEAM_ID` | No (App Check only) |

## Secrets management

`aiModelProxy` and `googlePlacesProxy` declare their secrets via
[`defineSecret`](https://firebase.google.com/docs/functions/config-env?gen=2nd#secret_parameters).
The declaration binds the secret to the function at deploy time — Firebase
validates the secret exists, grants the service account access automatically,
and caches the value at cold-start (no per-invocation Secret Manager call).

### Setting / rotating a secret

```bash
firebase functions:secrets:set OPENAI_KEY
firebase functions:secrets:set XAI_KEY
firebase functions:secrets:set GOOGLE_PLACES_API_KEY
```

After setting a secret, redeploy any function that consumes it for the new
value to take effect:

```bash
firebase deploy --only functions:aiModelProxy,functions:googlePlacesProxy
```

### Listing / inspecting secrets

```bash
firebase functions:secrets:access OPENAI_KEY      # print value
firebase functions:secrets:destroy OPENAI_KEY     # delete old version
gcloud secrets list                                # full inventory
```

## `aiModelProxy` — LLM provider proxy

Routes a unified chat-completion request to the appropriate upstream provider.

### Provider routing

Provider is resolved from the `model` field:

- `gpt-*` → OpenAI (`https://api.openai.com/v1/chat/completions`)
- `grok-*` → xAI (`https://api.x.ai/v1/chat/completions`, OpenAI-compatible)

Unknown prefixes are rejected with `invalid-argument`. There is no silent
fallback — a typo must never bill a different account.

### Request

```ts
{
  prompt: string;            // required
  model?: string;            // default "gpt-4o-mini"
  systemPrompt?: string;     // optional system message
  maxTokens?: number;        // optional
  temperature?: number;      // optional
}
```

### Response (unified across providers)

```ts
{
  text: string;
  model: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
}
```

### Security stack

1. **App Check** — `enforceAppCheck: true`. Requests without a valid token are
   rejected by the Firebase runtime before the handler runs.
2. **Firebase Auth** — handler requires `request.auth?.uid`. Unauthenticated
   callers get `unauthenticated`.
3. **Per-UID rate limit** — in-memory token bucket, 30 calls / 5 min per UID.
   Scope is per function instance; sufficient for our volume. If real abuse
   appears, swap the backing store in `middleware/rateLimit.ts` for Firestore.

Adding a new provider (e.g. Anthropic) is:

1. Add the provider to `LLMProvider` in `src/providers/llmProviders.ts`.
2. Add an entry to `PROVIDER_CONFIG` (base URL + auth headers).
3. Add a rule in `providerForModel` (`claude-*` → anthropic).
4. If the provider's HTTP schema differs from chat-completions, add an
   adapter in `mapRequest` / `mapResponse`.
5. Declare a new secret via `defineSecret("ANTHROPIC_KEY")` and add it to the
   function's `secrets: [...]` list.

## Local development

```bash
npm install
npm run build      # tsc → lib/
npm run lint
npm run serve      # firebase emulators:start --only functions
```

The emulator does not enforce App Check by default; pass a debug App Check
token from the simulator if needed. Secrets in the emulator come from
`.secret.local` — copy the development values there for local testing.

## Deploy

```bash
npm run build
firebase deploy --only functions
```

Or scope to one function:

```bash
firebase deploy --only functions:aiModelProxy
```
