import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

const GOOGLE_PLACES_API_KEY = defineSecret("GOOGLE_PLACES_API_KEY");

interface PlacesSearchRequest {
  query: string;
  radius?: number;
  maxResults?: number;
}

interface Place {
  id: string;
  displayName: string;
  formattedAddress: string;
  location?: {
    latitude: number;
    longitude: number;
  };
}

interface PlacesSearchResponse {
  places: Place[];
}

/**
 * Proxies Google Places API (New) requests through Cloud Functions.
 *
 * The Google Places API key lives in Firebase Secret Manager (declared via
 * `defineSecret`) and is loaded into the function runtime at cold-start —
 * it never reaches the device.
 *
 * App Check enforcement is enabled — requests without valid App Check
 * tokens are rejected automatically before the handler runs.
 *
 * Secret: GOOGLE_PLACES_API_KEY
 *   Set via: `firebase functions:secrets:set GOOGLE_PLACES_API_KEY`
 */
export const googlePlacesProxy = onCall(
  { secrets: [GOOGLE_PLACES_API_KEY], enforceAppCheck: true },
  async (request): Promise<PlacesSearchResponse> => {
    const {
      query,
      radius = 1000,
      maxResults = 20,
    } = request.data as PlacesSearchRequest;

    if (!query || query.trim().length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "`query` is required and must not be empty."
      );
    }

    const apiKey = GOOGLE_PLACES_API_KEY.value();

    const response = await fetch(
      "https://places.googleapis.com/v1/places:searchText",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": apiKey,
          "X-Goog-FieldMask":
            "places.id,places.displayName,places.formattedAddress,places.location",
        },
        body: JSON.stringify({
          textQuery: query,
          maxResultCount: maxResults,
          locationBias: radius ? { circle: { radius } } : undefined,
        }),
      }
    );

    if (!response.ok) {
      const errBody = await response.text().catch(() => "<unreadable>");
      console.error(
        `[googlePlacesProxy] status=${response.status} body=${errBody.slice(0, 500)}`
      );
      throw new HttpsError(
        "internal",
        `Places API returned ${response.status}.`
      );
    }

    const data = (await response.json()) as { places?: Record<string, unknown>[] };

    const places: Place[] = (data.places ?? []).map((place) => ({
      id: place["id"] as string,
      displayName:
        (place["displayName"] as { text?: string })?.text ??
        (place["id"] as string),
      formattedAddress: (place["formattedAddress"] as string) ?? "",
      location: place["location"] as Place["location"],
    }));

    return { places };
  }
);
