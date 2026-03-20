import { onCall } from "firebase-functions/v2/https";
import { getSecret } from "../config/secrets";

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
 * The Google Places API key is read from Secret Manager, keeping it
 * off the client device entirely.
 *
 * App Check enforcement is enabled — requests without valid App Check
 * tokens are rejected automatically before the handler runs.
 *
 * Secret Manager key: GOOGLE_PLACES_API_KEY
 */
export const googlePlacesProxy = onCall(
  { enforceAppCheck: true },
  async (request): Promise<PlacesSearchResponse> => {
    const {
      query,
      radius = 1000,
      maxResults = 20,
    } = request.data as PlacesSearchRequest;

    if (!query || query.trim().length === 0) {
      throw new Error("query is required and must not be empty");
    }

    const apiKey = await getSecret("GOOGLE_PLACES_API_KEY");

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
      throw new Error(
        `Places API error: ${response.status} ${response.statusText}`
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
