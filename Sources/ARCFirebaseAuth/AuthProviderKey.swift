//
//  AuthProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import SwiftUI

/// SwiftUI Environment key for auth provider.
///
/// This allows passing the auth provider through the SwiftUI environment:
///
/// ```swift
/// @main
/// struct FavResApp: App {
///     let auth: any AuthProviding
///
///     init() {
///         do {
///             auth = try FirebaseAuthProvider.create()
///         } catch {
///             fatalError("Firebase not configured: \(error)")
///         }
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.authProvider, auth)
///         }
///     }
/// }
///
/// struct MyView: View {
///     @Environment(\.authProvider) var auth
///
///     var body: some View {
///         Button("Sign In") {
///             Task {
///                 try await auth.signIn(email: email, password: password)
///             }
///         }
///     }
/// }
/// ```
///
/// - Important: You must explicitly set `.environment(\.authProvider, provider)` in your app.
///   The default value will crash if accessed without setting a provider first.
public struct AuthProviderKey: EnvironmentKey {
    public static let defaultValue: any AuthProviding = PlaceholderAuthProvider()
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderAuthProvider: AuthProviding, @unchecked Sendable {
    var currentUser: User? {
        placeholderCrash()
    }

    var isAuthenticated: Bool {
        placeholderCrash()
    }

    func signIn(email _: String, password _: String) async throws -> User {
        placeholderCrash()
    }

    func signUp(email _: String, password _: String) async throws -> User {
        placeholderCrash()
    }

    func signOut() async throws {
        placeholderCrash()
    }

    func sendPasswordReset(email _: String) async throws {
        placeholderCrash()
    }

    func updatePassword(_: String) async throws {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError(
            """
            AuthProvider not configured.
            You must set the auth provider in your app's environment:

                .environment(\\.authProvider, authProvider)

            Or use a mock provider for previews/testing:

                .environment(\\.authProvider, MockAuthProvider())
            """
        )
    }
}

extension EnvironmentValues {
    /// The authentication provider in the environment.
    public var authProvider: any AuthProviding {
        get { self[AuthProviderKey.self] }
        set { self[AuthProviderKey.self] = newValue }
    }
}
