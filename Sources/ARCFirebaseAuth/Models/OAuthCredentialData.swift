//
//  OAuthCredentialData.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-27.
//

import Foundation

/// Data required to authenticate with an OAuth provider.
///
/// This struct keeps the ``AuthProviding`` protocol Firebase-agnostic by
/// decoupling credential data from Firebase's `AuthCredential` type.
/// The ``FirebaseAuthProvider`` maps this to Firebase credentials internally.
///
/// ## Usage
///
/// ```swift
/// // Google Sign-In
/// let credential = OAuthCredentialData(
///     providerID: "google.com",
///     idToken: googleIDToken,
///     accessToken: googleAccessToken
/// )
///
/// // Apple Sign-In
/// let credential = OAuthCredentialData(
///     providerID: "apple.com",
///     idToken: appleIDToken,
///     rawNonce: nonce,
///     authorizationCode: appleAuthorizationCode
/// )
///
/// let user = try await auth.signIn(with: credential)
/// ```
public struct OAuthCredentialData: Sendable {
    /// The OAuth provider identifier (e.g., "google.com", "apple.com").
    public let providerID: String

    /// The ID token from the OAuth provider, if available.
    public let idToken: String?

    /// The access token from the OAuth provider, if available.
    public let accessToken: String?

    /// The raw nonce used for Apple Sign-In verification, if applicable.
    public let rawNonce: String?

    /// The short-lived Apple authorization code, if applicable.
    ///
    /// Only ``AuthProviding/revokeToken(authorizationCode:)`` consumes this — it is not
    /// part of the sign-in credential Firebase builds. Apple invalidates the code after
    /// about five minutes and allows a single use, so it cannot be stored and replayed;
    /// obtain a fresh one by re-running Sign in with Apple at the moment you need it.
    public let authorizationCode: String?

    /// Creates OAuth credential data.
    ///
    /// - Parameters:
    ///   - providerID: The OAuth provider identifier (e.g., "google.com", "apple.com").
    ///   - idToken: The ID token from the OAuth provider.
    ///   - accessToken: The access token from the OAuth provider.
    ///   - rawNonce: The raw nonce for Apple Sign-In verification.
    ///   - authorizationCode: The short-lived Apple authorization code, used for token revocation.
    public init(providerID: String,
                idToken: String? = nil,
                accessToken: String? = nil,
                rawNonce: String? = nil,
                authorizationCode: String? = nil) {
        self.providerID = providerID
        self.idToken = idToken
        self.accessToken = accessToken
        self.rawNonce = rawNonce
        self.authorizationCode = authorizationCode
    }
}
