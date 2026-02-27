//
//  FirebaseAuthProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseAuth
import Foundation

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
/// - ``signIn(with:)``
/// - ``authStateChanges()``
/// - ``deleteAccount()``
/// - ``linkAccount(with:)``
/// - ``unlinkProvider(_:)``
/// - ``linkedProviders()``
public final class FirebaseAuthProvider: AuthProviding, @unchecked Sendable {
    // MARK: - Properties

    private let auth = Auth.auth()
    private let logger = ARCLogger(subsystem: "com.arclabs-studio.arcfirebase", category: "FirebaseAuth")

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
        logger.info("Attempting sign in")

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
        logger.info("Attempting sign up")

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
        logger.info("Sending password reset email")

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

    // MARK: - OAuth Sign-In

    public func signIn(with credential: OAuthCredentialData) async throws -> User {
        logger.info("Attempting OAuth sign in with provider: \(credential.providerID)")

        do {
            let authCredential = Self.makeOAuthCredential(from: credential)
            let result = try await auth.signIn(with: authCredential)
            let user = User(from: result.user)
            logger.info("OAuth sign in successful: \(user.id)")
            return user
        } catch {
            logger.error("OAuth sign in failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    // MARK: - Auth State Observation

    public func authStateChanges() -> AsyncStream<User?> {
        let auth = auth
        return AsyncStream { continuation in
            let handle = auth.addStateDidChangeListener { _, firebaseUser in
                let user = firebaseUser.map { User(from: $0) }
                continuation.yield(user)
            }

            let sendableHandle = UncheckedSendableBox(handle)
            continuation.onTermination = { _ in
                auth.removeStateDidChangeListener(sendableHandle.value)
            }
        }
    }

    // MARK: - Account Management

    public func deleteAccount() async throws {
        logger.info("Attempting to delete account")

        guard let currentUser = auth.currentUser else {
            logger.error("No user signed in")
            throw FirebaseError.userNotFound
        }

        do {
            try await currentUser.delete()
            logger.info("Account deleted successfully")
        } catch {
            logger.error("Account deletion failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func linkAccount(with credential: OAuthCredentialData) async throws -> User {
        logger.info("Attempting to link provider: \(credential.providerID)")

        guard let currentUser = auth.currentUser else {
            logger.error("No user signed in")
            throw FirebaseError.userNotFound
        }

        do {
            let authCredential = Self.makeOAuthCredential(from: credential)
            let result = try await currentUser.link(with: authCredential)
            let user = User(from: result.user)
            logger.info("Provider linked successfully: \(credential.providerID)")
            return user
        } catch {
            logger.error("Provider linking failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func unlinkProvider(_ providerID: String) async throws -> User {
        logger.info("Attempting to unlink provider: \(providerID)")

        guard let currentUser = auth.currentUser else {
            logger.error("No user signed in")
            throw FirebaseError.userNotFound
        }

        do {
            let firebaseUser = try await currentUser.unlink(fromProvider: providerID)
            let user = User(from: firebaseUser)
            logger.info("Provider unlinked successfully: \(providerID)")
            return user
        } catch {
            logger.error("Provider unlinking failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func linkedProviders() async -> [String] {
        auth.currentUser?.providerData.map(\.providerID) ?? []
    }

    // MARK: - Private Helpers

    private static func makeOAuthCredential(from credential: OAuthCredentialData) -> OAuthCredential {
        let providerID = AuthProviderID.custom(credential.providerID)

        if let rawNonce = credential.rawNonce, let idToken = credential.idToken {
            return OAuthProvider.credential(providerID: providerID,
                                            idToken: idToken,
                                            rawNonce: rawNonce,
                                            accessToken: credential.accessToken)
        } else if let idToken = credential.idToken {
            return OAuthProvider.credential(providerID: providerID,
                                            idToken: idToken,
                                            accessToken: credential.accessToken)
        } else if let accessToken = credential.accessToken {
            return OAuthProvider.credential(providerID: providerID,
                                            accessToken: accessToken)
        } else {
            return OAuthProvider.credential(providerID: providerID,
                                            idToken: "",
                                            accessToken: nil)
        }
    }
}

// MARK: - Firebase User Mapping

extension User {
    fileprivate init(from firebaseUser: FirebaseAuth.User) {
        self.init(id: firebaseUser.uid,
                  email: firebaseUser.email,
                  displayName: firebaseUser.displayName,
                  photoURL: firebaseUser.photoURL,
                  isEmailVerified: firebaseUser.isEmailVerified,
                  creationDate: firebaseUser.metadata.creationDate,
                  lastSignInDate: firebaseUser.metadata.lastSignInDate,
                  providerID: firebaseUser.providerID,
                  linkedProviderIDs: firebaseUser.providerData.map(\.providerID))
    }
}

// MARK: - Factory Methods

extension FirebaseAuthProvider {
    /// Creates a new instance with explicit error handling.
    ///
    /// Use this method when you want to handle initialization errors:
    ///
    /// ```swift
    /// do {
    ///     let auth = try FirebaseAuthProvider.create()
    /// } catch {
    ///     // Handle configuration error
    /// }
    /// ```
    ///
    /// - Returns: A configured ``FirebaseAuthProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create() throws -> FirebaseAuthProvider {
        try FirebaseAuthProvider()
    }

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
        do {
            return try create()
        } catch {
            fatalError("""
            FirebaseAuthProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(error.localizedDescription)
            """)
        }
    }
}

// MARK: - Sendable Wrapper

/// Wraps a non-Sendable value for use in `@Sendable` closures where safety is guaranteed by design.
private struct UncheckedSendableBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}
