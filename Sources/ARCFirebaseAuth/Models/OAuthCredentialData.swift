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
///     rawNonce: nonce
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

    /// Creates OAuth credential data.
    ///
    /// - Parameters:
    ///   - providerID: The OAuth provider identifier (e.g., "google.com", "apple.com").
    ///   - idToken: The ID token from the OAuth provider.
    ///   - accessToken: The access token from the OAuth provider.
    ///   - rawNonce: The raw nonce for Apple Sign-In verification.
    public init(
        providerID: String,
        idToken: String? = nil,
        accessToken: String? = nil,
        rawNonce: String? = nil
    ) {
        self.providerID = providerID
        self.idToken = idToken
        self.accessToken = accessToken
        self.rawNonce = rawNonce
    }
}
