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
/// @Observable
/// @MainActor
/// final class MyViewModel {
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
}
