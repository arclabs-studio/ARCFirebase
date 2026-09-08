//
//  AuthProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import SwiftUI

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

    func signIn(with _: OAuthCredentialData) async throws -> User {
        placeholderCrash()
    }

    func reauthenticate(with _: OAuthCredentialData) async throws -> User {
        placeholderCrash()
    }

    func authStateChanges() -> AsyncStream<User?> {
        placeholderCrash()
    }

    func revokeToken(authorizationCode _: String) async throws {
        placeholderCrash()
    }

    func deleteAccount() async throws {
        placeholderCrash()
    }

    func linkAccount(with _: OAuthCredentialData) async throws -> User {
        placeholderCrash()
    }

    func unlinkProvider(_: String) async throws -> User {
        placeholderCrash()
    }

    func linkedProviders() async -> [String] {
        placeholderCrash()
    }

    func sendEmailVerification() async throws {
        placeholderCrash()
    }

    func updateProfile(displayName _: String?, photoURL _: URL?) async throws {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError("""
        AuthProvider not configured.
        You must set the auth provider in your app's environment:

            .environment(\\.authProvider, authProvider)

        Or use a mock provider for previews/testing:

            .environment(\\.authProvider, MockAuthProvider())
        """)
    }
}

extension EnvironmentValues {
    /// The authentication provider in the environment.
    @Entry public var authProvider: any AuthProviding = PlaceholderAuthProvider()
}
