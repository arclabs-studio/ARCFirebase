import Foundation
import FirebaseAuth
import ARCFirebaseCore
import ARCLogger

/// Firebase implementation of ``AuthProviding``.
///
/// This is the production authentication provider that uses Firebase Auth.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance
/// let auth = try FirebaseAuthProvider()
///
/// // Or use the convenience default
/// let auth = FirebaseAuthProvider.live
/// ```
///
/// ## SwiftUI Integration
///
/// ```swift
/// @main
/// struct FavResApp: App {
///     let auth = FirebaseAuthProvider.live
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.authProvider, auth)
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
/// - ``live``
///
/// ### AuthProviding Implementation
/// - ``currentUser``
/// - ``isAuthenticated``
/// - ``signIn(email:password:)``
/// - ``signUp(email:password:)``
/// - ``signOut()``
/// - ``sendPasswordReset(email:)``
/// - ``updatePassword(_:)``
public final class FirebaseAuthProvider: AuthProviding, @unchecked Sendable {

    // MARK: - Properties

    private let auth = Auth.auth()
    private let logger = ARCLogger(category: "FirebaseAuth")

    // MARK: - Initialization

    /// Creates a Firebase authentication provider.
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init() throws {
        try FirebaseManager.ensureConfigured()
        logger.info("FirebaseAuthProvider initialized")
    }

    // MARK: - AuthProviding Implementation

    public var currentUser: User? {
        get async {
            guard let firebaseUser = auth.currentUser else { return nil }
            return User(from: firebaseUser)
        }
    }

    public var isAuthenticated: Bool {
        get async {
            await currentUser != nil
        }
    }

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

    public func signOut() async throws {
        logger.info("Attempting sign out")

        do {
            try auth.signOut()
            logger.info("Sign out successful")
        } catch {
            logger.error("Sign out failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func sendPasswordReset(email: String) async throws {
        logger.info("Sending password reset email to: \(email)")

        do {
            try await auth.sendPasswordReset(withEmail: email)
            logger.info("Password reset email sent")
        } catch {
            logger.error("Failed to send password reset: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func updatePassword(_ newPassword: String) async throws {
        logger.info("Attempting to update password")

        guard let currentUser = auth.currentUser else {
            logger.error("No user signed in")
            throw FirebaseError.authNotAvailable
        }

        do {
            try await currentUser.updatePassword(to: newPassword)
            logger.info("Password updated successfully")
        } catch {
            logger.error("Failed to update password: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }
}

// MARK: - Convenience

extension FirebaseAuthProvider {

    /// Default live instance for production use.
    ///
    /// Use this for convenience in production code:
    ///
    /// ```swift
    /// let auth = FirebaseAuthProvider.live
    /// ```
    ///
    /// - Important: This will crash if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first.
    public static var live: FirebaseAuthProvider {
        // Force unwrap is intentional - if Firebase isn't configured,
        // we want to crash early in development
        try! FirebaseAuthProvider()
    }
}
