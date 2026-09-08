//
//  AuthProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import Foundation

/// Protocol defining authentication capabilities.
///
/// Use this protocol for dependency injection to make your code testable
/// and decoupled from Firebase.
///
/// ## Usage in Production
///
/// ```swift
/// @MainActor
/// @Observable final class MyViewModel {
///     private let auth: AuthProviding
///
///     init(auth: AuthProviding) {
///         self.auth = auth
///     }
///
///     func signIn() async throws {
///         let user = try await auth.signIn(email: email, password: password)
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// struct MockAuthProvider: AuthProviding {
///     var mockUser: User?
///
///     var currentUser: User? {
///         get async { mockUser }
///     }
///
///     var isAuthenticated: Bool {
///         get async { mockUser != nil }
///     }
///
///     func signIn(email: String, password: String) async throws -> User {
///         return mockUser ?? User(id: "test", email: email, displayName: nil,
///                                 photoURL: nil, isEmailVerified: false,
///                                 creationDate: nil, lastSignInDate: nil)
///     }
///
///     func signUp(email: String, password: String) async throws -> User {
///         return mockUser ?? User(id: "test", email: email, displayName: nil,
///                                 photoURL: nil, isEmailVerified: false,
///                                 creationDate: nil, lastSignInDate: nil)
///     }
///
///     func signOut() throws {}
///     func sendPasswordReset(email: String) async throws {}
///     func updatePassword(_ newPassword: String) async throws {}
/// }
///
/// func testViewModel() async throws {
///     let mock = MockAuthProvider(mockUser: testUser)
///     let viewModel = MyViewModel(auth: mock)
///     // Test without touching Firebase
/// }
/// ```
///
/// ## Topics
///
/// ### Current User
/// - ``currentUser``
/// - ``isAuthenticated``
///
/// ### Sign In/Up/Out
/// - ``signIn(email:password:)``
/// - ``signUp(email:password:)``
/// - ``signOut()``
///
/// ### Password Management
/// - ``sendPasswordReset(email:)``
/// - ``updatePassword(_:)``
///
/// ### OAuth Sign-In
/// - ``signIn(with:)``
/// - ``reauthenticate(with:)``
///
/// ### Auth State
/// - ``authStateChanges()``
///
/// ### Account Management
/// - ``deleteAccount()``
/// - ``revokeToken(authorizationCode:)``
/// - ``linkAccount(with:)``
/// - ``unlinkProvider(_:)``
/// - ``linkedProviders()``
///
/// ### Email Verification
/// - ``sendEmailVerification()``
///
/// ### Profile
/// - ``updateProfile(displayName:photoURL:)``
///
/// ### Implementations
/// - ``FirebaseAuthProvider``
public protocol AuthProviding: Sendable {
    /// The currently authenticated user, if any.
    var currentUser: User? { get async }

    /// Indicates whether a user is currently authenticated.
    var isAuthenticated: Bool { get async }

    /// Signs in a user with email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The authenticated user.
    /// - Throws: Authentication errors.
    func signIn(email: String, password: String) async throws -> User

    /// Creates a new user account with email and password.
    ///
    /// - Parameters:
    ///   - email: The new user's email address.
    ///   - password: The new user's password.
    /// - Returns: The newly created user.
    /// - Throws: Authentication errors.
    func signUp(email: String, password: String) async throws -> User

    /// Signs out the currently authenticated user.
    ///
    /// - Throws: Sign out errors.
    func signOut() async throws

    /// Sends a password reset email.
    ///
    /// - Parameter email: The user's email address.
    /// - Throws: Password reset errors.
    func sendPasswordReset(email: String) async throws

    /// Updates the current user's password.
    ///
    /// - Parameter newPassword: The new password.
    /// - Throws: Password update errors.
    func updatePassword(_ newPassword: String) async throws

    // MARK: - OAuth Sign-In

    /// Signs in a user with OAuth credentials from an identity provider.
    ///
    /// Use this for third-party authentication (e.g., Google, Apple).
    /// The caller is responsible for obtaining the credential data from the provider SDK.
    ///
    /// - Parameter credential: The OAuth credential data from the identity provider.
    /// - Returns: The authenticated user.
    /// - Throws: ``FirebaseError/invalidCredential`` if the credential is invalid.
    func signIn(with credential: OAuthCredentialData) async throws -> User

    /// Re-authenticates the current user with a freshly obtained OAuth credential.
    ///
    /// Security-sensitive operations — deleting the account, changing the primary email —
    /// require a recent sign-in. Call this with a credential obtained moments earlier to
    /// clear ``FirebaseError/requiresRecentLogin`` before attempting one.
    ///
    /// - Parameter credential: A freshly obtained OAuth credential for the signed-in user.
    /// - Returns: The re-authenticated user.
    /// - Throws: ``FirebaseError/userNotFound`` if no user is signed in.
    /// - Throws: ``FirebaseError/invalidCredential`` if the credential is invalid or stale.
    func reauthenticate(with credential: OAuthCredentialData) async throws -> User

    // MARK: - Auth State Observation

    /// Returns an asynchronous stream of authentication state changes.
    ///
    /// The stream emits the current user whenever the auth state changes
    /// (sign in, sign out, token refresh). Emits `nil` when no user is signed in.
    ///
    /// - Returns: An `AsyncStream` that emits `User?` on each auth state change.
    func authStateChanges() -> AsyncStream<User?>

    // MARK: - Account Management

    /// Deletes the currently authenticated user's account.
    ///
    /// - Throws: ``FirebaseError/userNotFound`` if no user is signed in.
    /// - Throws: ``FirebaseError/requiresRecentLogin`` if re-authentication is needed.
    func deleteAccount() async throws

    /// Revokes the user's Apple tokens ahead of deleting their account.
    ///
    /// Apps offering Sign in with Apple must revoke the user's tokens when the account is
    /// deleted, not merely delete the account — see
    /// [Apple's account deletion guidance](https://developer.apple.com/support/offering-account-deletion-in-your-app/).
    ///
    /// Call this **before** ``deleteAccount()``: the request carries the signed-in user's
    /// ID token, so it fails once the account is gone. The authorization code must be
    /// freshly obtained — Apple's codes are single-use and expire after about five minutes.
    ///
    /// Requires the *Services ID* and *OAuth code flow configuration* to be filled in on the
    /// Apple provider in the Firebase console; without them the backend cannot exchange the
    /// code and the call fails with `Code flow is not enabled for Apple`.
    ///
    /// - Parameter authorizationCode: A fresh Apple authorization code.
    /// - Throws: ``FirebaseError/userNotFound`` if no user is signed in.
    /// - Throws: ``FirebaseError/invalidCredential`` if the code is stale, already used, or
    ///   the provider's code flow is not configured.
    func revokeToken(authorizationCode: String) async throws

    /// Links an OAuth credential to the current user's account.
    ///
    /// - Parameter credential: The OAuth credential data to link.
    /// - Returns: The updated user with the new provider linked.
    /// - Throws: ``FirebaseError/providerAlreadyLinked`` if the provider is already linked.
    func linkAccount(with credential: OAuthCredentialData) async throws -> User

    /// Unlinks a provider from the current user's account.
    ///
    /// - Parameter providerID: The provider ID to unlink (e.g., "google.com").
    /// - Returns: The updated user after unlinking.
    /// - Throws: ``FirebaseError/noSuchProvider`` if the provider is not linked.
    func unlinkProvider(_ providerID: String) async throws -> User

    /// Returns the IDs of all providers linked to the current user.
    ///
    /// - Returns: An array of provider IDs, or an empty array if no user is signed in.
    func linkedProviders() async -> [String]

    // MARK: - Email Verification

    /// Sends a verification email to the current user's email address.
    ///
    /// - Throws: ``FirebaseError/userNotFound`` if no user is signed in.
    /// - Throws: Network or Firebase errors if sending fails.
    func sendEmailVerification() async throws

    // MARK: - Profile Update

    /// Updates the current user's display name and/or photo URL.
    ///
    /// - Parameters:
    ///   - displayName: The new display name, or `nil` to leave unchanged.
    ///   - photoURL: The new photo URL, or `nil` to leave unchanged.
    /// - Throws: ``FirebaseError/userNotFound`` if no user is signed in.
    func updateProfile(displayName: String?, photoURL: URL?) async throws
}
