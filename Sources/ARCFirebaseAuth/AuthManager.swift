import Foundation
import FirebaseAuth
import ARCFirebaseCore
import ARCLogger

/// Manages user authentication with Firebase Authentication.
///
/// `AuthManager` provides a simplified interface to Firebase Auth with support
/// for email/password, Sign in with Apple, and other authentication methods.
///
/// ## Topics
///
/// ### Configuration
/// - ``configure()``
///
/// ### Sign In/Out
/// - ``signIn(email:password:)``
/// - ``signUp(email:password:)``
/// - ``signOut()``
///
/// ### Current User
/// - ``currentUser``
/// - ``isAuthenticated``
///
/// ### User Guide
/// - <doc:AuthenticationGuide>
public final class AuthManager {

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = AuthManager()

    // MARK: - Properties

    private let logger = ARCLogger(category: "Auth")
    private let auth = Auth.auth()

    /// The currently authenticated user, if any.
    ///
    /// Returns `nil` if no user is signed in.
    public var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(from: firebaseUser)
    }

    /// Indicates whether a user is currently authenticated.
    public var isAuthenticated: Bool {
        currentUser != nil
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Configuration

    /// Configures the auth manager.
    ///
    /// Call this after Firebase is configured.
    ///
    /// ```swift
    /// FirebaseManager.configure()
    /// try AuthManager.shared.configure()
    /// ```
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public func configure() throws {
        try FirebaseManager.shared.ensureConfigured()
        logger.info("AuthManager configured successfully")
    }

    // MARK: - Sign In

    /// Signs in a user with email and password.
    ///
    /// ```swift
    /// do {
    ///     let user = try await AuthManager.shared.signIn(
    ///         email: "user@example.com",
    ///         password: "password123"
    ///     )
    ///     print("Signed in: \(user.email)")
    /// } catch {
    ///     print("Sign in failed: \(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The authenticated ``User``.
    /// - Throws: Firebase authentication errors.
    public func signIn(email: String, password: String) async throws -> User {
        logger.info("Attempting sign in for email: \(email)")

        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            let user = User(from: result.user)
            logger.info("Sign in successful: \(user.id)")
            return user
        } catch {
            logger.error("Sign in failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    // MARK: - Sign Up

    /// Creates a new user account with email and password.
    ///
    /// ```swift
    /// do {
    ///     let user = try await AuthManager.shared.signUp(
    ///         email: "newuser@example.com",
    ///         password: "securePassword123"
    ///     )
    ///     print("Account created: \(user.email)")
    /// } catch {
    ///     print("Sign up failed: \(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - email: The new user's email address.
    ///   - password: The new user's password (must meet Firebase requirements).
    /// - Returns: The newly created ``User``.
    /// - Throws: Firebase authentication errors.
    public func signUp(email: String, password: String) async throws -> User {
        logger.info("Attempting sign up for email: \(email)")

        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User(from: result.user)
            logger.info("Sign up successful: \(user.id)")
            return user
        } catch {
            logger.error("Sign up failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    // MARK: - Sign Out

    /// Signs out the currently authenticated user.
    ///
    /// ```swift
    /// do {
    ///     try AuthManager.shared.signOut()
    ///     print("User signed out")
    /// } catch {
    ///     print("Sign out failed: \(error)")
    /// }
    /// ```
    ///
    /// - Throws: Firebase authentication errors.
    public func signOut() throws {
        logger.info("Attempting sign out")

        do {
            try auth.signOut()
            logger.info("Sign out successful")
        } catch {
            logger.error("Sign out failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }
}
