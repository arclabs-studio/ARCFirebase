import { onCall } from "firebase-functions/v2/https";
import { createSign } from "crypto";
import { getSecret } from "../config/secrets";

interface DeviceCheckRequest {
  deviceToken: string;
  bundleId: string;
}

interface DeviceCheckResponse {
  valid: boolean;
  bitZero?: boolean;
  bitOne?: boolean;
}

const APPLE_DEVICE_CHECK_URL =
  "https://api.devicecheck.apple.com/v1/validate_device_token";
const APPLE_DEVICE_CHECK_DEV_URL =
  "https://api.development.devicecheck.apple.com/v1/validate_device_token";

/**
 * Validates an iOS device token using Apple's DeviceCheck API.
 *
 * The DeviceCheck private key (.p8 content) and credentials are read from
 * Secret Manager, keeping them off the client device entirely.
 *
 * App Check enforcement is enabled — requests without valid App Check
 * tokens are rejected automatically before the handler runs.
 *
 * Secret Manager keys:
 *   - DEVICECHECK_PRIVATE_KEY: The .p8 private key file content
 *   - DEVICECHECK_KEY_ID: The Key ID from your Apple Developer account
 *   - DEVICECHECK_TEAM_ID: Your Apple Developer Team ID
 *
 * Environment variables:
 *   - APPLE_DEVICE_CHECK_DEV: Set to "true" to use the development API endpoint
 */
export const deviceCheckValidation = onCall(
  { enforceAppCheck: true },
  async (request): Promise<DeviceCheckResponse> => {
    const { deviceToken, bundleId } = request.data as DeviceCheckRequest;

    if (!deviceToken) {
      throw new Error("deviceToken is required");
    }

    if (!bundleId) {
      throw new Error("bundleId is required");
    }

    const [privateKey, keyId, teamId] = await Promise.all([
      getSecret("DEVICECHECK_PRIVATE_KEY"),
      getSecret("DEVICECHECK_KEY_ID"),
      getSecret("DEVICECHECK_TEAM_ID"),
    ]);

    const jwt = generateDeviceCheckJWT(privateKey, keyId, teamId);

    const isDevelopment = process.env.APPLE_DEVICE_CHECK_DEV === "true";
    const url = isDevelopment ? APPLE_DEVICE_CHECK_DEV_URL : APPLE_DEVICE_CHECK_URL;

    const response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${jwt}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        device_token: deviceToken,
        transaction_id: generateTransactionId(),
        timestamp: Date.now(),
      }),
    });

    if (!response.ok) {
      return { valid: false };
    }

    const data = (await response.json()) as { bit0?: boolean; bit1?: boolean };
    return {
      valid: true,
      bitZero: data.bit0,
      bitOne: data.bit1,
    };
  }
);

function generateDeviceCheckJWT(
  privateKeyPEM: string,
  keyId: string,
  teamId: string
): string {
  const header = Buffer.from(
    JSON.stringify({ alg: "ES256", kid: keyId })
  ).toString("base64url");

  const payload = Buffer.from(
    JSON.stringify({
      iss: teamId,
      iat: Math.floor(Date.now() / 1000),
    })
  ).toString("base64url");

  const message = `${header}.${payload}`;
  const sign = createSign("SHA256");
  sign.update(message);
  const signature = sign.sign(privateKeyPEM, "base64url");

  return `${message}.${signature}`;
}

function generateTransactionId(): string {
  return Buffer.from(
    Array.from({ length: 16 }, () => Math.floor(Math.random() * 256))
  ).toString("base64");
}
