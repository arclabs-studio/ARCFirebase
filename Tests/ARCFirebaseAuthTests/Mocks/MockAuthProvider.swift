import Foundation
import os
@testable import ARCFirebaseAuth

/// Mock authentication provider for testing.
final class MockAuthProvider: AuthProviding {
    private struct State {
        var mockUser: User?
        var mockError: Error?
        var mockLinkedProviders: [String] = []
        var mockAuthStateUsers: [User?] = []
        var signInCallCount: Int = 0
        var signUpCallCount: Int = 0
        var signOutCallCount: Int = 0
        var passwordResetCallCount: Int = 0
        var updatePasswordCallCount: Int = 0
        var oauthSignInCallCount: Int = 0
        var reauthenticateCallCount: Int = 0
        var revokeTokenCallCount: Int = 0
        var lastAuthorizationCode: String?
        var lastReauthenticateCredential: OAuthCredentialData?
        var deleteAccountCallCount: Int = 0
        var linkAccountCallCount: Int = 0
        var unlinkProviderCallCount: Int = 0
        var linkedProvidersCallCount: Int = 0
        var authStateChangesCallCount: Int = 0
        var sendEmailVerificationCallCount: Int = 0
        var updateProfileCallCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var mockUser: User? {
        get { state.withLock { $0.mockUser } }
        set { state.withLock { $0.mockUser = newValue } }
    }

    var mockError: Error? {
        get { state.withLock { $0.mockError } }
        set { state.withLock { $0.mockError = newValue } }
    }

    var mockLinkedProviders: [String] {
        get { state.withLock { $0.mockLinkedProviders } }
        set { state.withLock { $0.mockLinkedProviders = newValue } }
    }

    var mockAuthStateUsers: [User?] {
        get { state.withLock { $0.mockAuthStateUsers } }
        set { state.withLock { $0.mockAuthStateUsers = newValue } }
    }

    var signInCallCount: Int {
        state.withLock { $0.signInCallCount }
    }

    var signUpCallCount: Int {
        state.withLock { $0.signUpCallCount }
    }

    var signOutCallCount: Int {
        state.withLock { $0.signOutCallCount }
    }

    var passwordResetCallCount: Int {
        state.withLock { $0.passwordResetCallCount }
    }

    var updatePasswordCallCount: Int {
        state.withLock { $0.updatePasswordCallCount }
    }

    var oauthSignInCallCount: Int {
        state.withLock { $0.oauthSignInCallCount }
    }

    var reauthenticateCallCount: Int {
        state.withLock { $0.reauthenticateCallCount }
    }

    var revokeTokenCallCount: Int {
        state.withLock { $0.revokeTokenCallCount }
    }

    var lastAuthorizationCode: String? {
        state.withLock { $0.lastAuthorizationCode }
    }

    var lastReauthenticateCredential: OAuthCredentialData? {
        state.withLock { $0.lastReauthenticateCredential }
    }

    var deleteAccountCallCount: Int {
        state.withLock { $0.deleteAccountCallCount }
    }

    var linkAccountCallCount: Int {
        state.withLock { $0.linkAccountCallCount }
    }

    var unlinkProviderCallCount: Int {
        state.withLock { $0.unlinkProviderCallCount }
    }

    var linkedProvidersCallCount: Int {
        state.withLock { $0.linkedProvidersCallCount }
    }

    var authStateChangesCallCount: Int {
        state.withLock { $0.authStateChangesCallCount }
    }

    var sendEmailVerificationCallCount: Int {
        state.withLock { $0.sendEmailVerificationCallCount }
    }

    var updateProfileCallCount: Int {
        state.withLock { $0.updateProfileCallCount }
    }

    // MARK: - AuthProviding Implementation

    var currentUser: User? {
        get async { mockUser }
    }

    var isAuthenticated: Bool {
        get async { mockUser != nil }
    }

    func signIn(email: String, password _: String) async throws -> User {
        state.withLock { $0.signInCallCount += 1 }

        if let error = mockError {
            throw error
        }

        if let user = mockUser {
            return user
        }

        // Create a default mock user
        let user = User(id: "mock-user-id", email: email)
        state.withLock { [user] in $0.mockUser = user }
        return user
    }

    func signUp(email: String, password _: String) async throws -> User {
        state.withLock { $0.signUpCallCount += 1 }

        if let error = mockError {
            throw error
        }

        let user = User(id: "new-user-\(UUID().uuidString)", email: email)
        state.withLock { [user] in $0.mockUser = user }
        return user
    }

    func signOut() async throws {
        state.withLock { $0.signOutCallCount += 1 }

        if let error = mockError {
            throw error
        }

        state.withLock { $0.mockUser = nil }
    }

    func sendPasswordReset(email _: String) async throws {
        state.withLock { $0.passwordResetCallCount += 1 }

        if let error = mockError {
            throw error
        }
    }

    func updatePassword(_: String) async throws {
        state.withLock { $0.updatePasswordCallCount += 1 }

        if let error = mockError {
            throw error
        }
    }

    func signIn(with credential: OAuthCredentialData) async throws -> User {
        state.withLock { $0.oauthSignInCallCount += 1 }

        if let error = mockError {
            throw error
        }

        if let user = mockUser {
            return user
        }

        let user = User(id: "oauth-user-id",
                        email: "oauth@example.com",
                        providerID: credential.providerID,
                        linkedProviderIDs: [credential.providerID])
        state.withLock { [user] in $0.mockUser = user }
        return user
    }

    func reauthenticate(with credential: OAuthCredentialData) async throws -> User {
        state.withLock { $0.reauthenticateCallCount += 1 }
        state.withLock { $0.lastReauthenticateCredential = credential }

        if let error = mockError {
            throw error
        }

        if let user = mockUser {
            return user
        }

        let user = User(id: "oauth-user-id",
                        email: "oauth@example.com",
                        providerID: credential.providerID,
                        linkedProviderIDs: [credential.providerID])
        state.withLock { [user] in $0.mockUser = user }
        return user
    }

    func revokeToken(authorizationCode: String) async throws {
        state.withLock { $0.revokeTokenCallCount += 1 }
        state.withLock { $0.lastAuthorizationCode = authorizationCode }

        if let error = mockError {
            throw error
        }
    }

    func authStateChanges() -> AsyncStream<User?> {
        state.withLock { $0.authStateChangesCallCount += 1 }

        let users = mockAuthStateUsers
        return AsyncStream { continuation in
            for user in users {
                continuation.yield(user)
            }
            continuation.finish()
        }
    }

    func deleteAccount() async throws {
        state.withLock { $0.deleteAccountCallCount += 1 }

        if let error = mockError {
            throw error
        }

        state.withLock { $0.mockUser = nil }
    }

    func linkAccount(with credential: OAuthCredentialData) async throws -> User {
        state.withLock { $0.linkAccountCallCount += 1 }

        if let error = mockError {
            throw error
        }

        guard var user = mockUser else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }

        let updatedProviders = user.linkedProviderIDs + [credential.providerID]
        user = User(id: user.id,
                    email: user.email,
                    displayName: user.displayName,
                    photoURL: user.photoURL,
                    isEmailVerified: user.isEmailVerified,
                    creationDate: user.creationDate,
                    lastSignInDate: user.lastSignInDate,
                    providerID: user.providerID,
                    linkedProviderIDs: updatedProviders)
        state.withLock { [user] in $0.mockUser = user }
        return user
    }

    func unlinkProvider(_ providerID: String) async throws -> User {
        state.withLock { $0.unlinkProviderCallCount += 1 }

        if let error = mockError {
            throw error
        }

        guard var user = mockUser else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }

        let updatedProviders = user.linkedProviderIDs.filter { $0 != providerID }
        user = User(id: user.id,
                    email: user.email,
                    displayName: user.displayName,
                    photoURL: user.photoURL,
                    isEmailVerified: user.isEmailVerified,
                    creationDate: user.creationDate,
                    lastSignInDate: user.lastSignInDate,
                    providerID: user.providerID,
                    linkedProviderIDs: updatedProviders)
        state.withLock { [user] in $0.mockUser = user }
        return user
    }

    func linkedProviders() async -> [String] {
        state.withLock { $0.linkedProvidersCallCount += 1 }
        return mockLinkedProviders
    }

    func sendEmailVerification() async throws {
        state.withLock { $0.sendEmailVerificationCallCount += 1 }

        if let error = mockError {
            throw error
        }
    }

    func updateProfile(displayName: String?, photoURL _: URL?) async throws {
        state.withLock { $0.updateProfileCallCount += 1 }
        if let error = mockError {
            throw error
        }
        if let name = displayName, var user = mockUser {
            user = User(id: user.id,
                        email: user.email,
                        displayName: name,
                        photoURL: user.photoURL,
                        isEmailVerified: user.isEmailVerified,
                        creationDate: user.creationDate,
                        lastSignInDate: user.lastSignInDate,
                        providerID: user.providerID,
                        linkedProviderIDs: user.linkedProviderIDs)
            state.withLock { [user] in $0.mockUser = user }
        }
    }

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.mockUser = nil }
        state.withLock { $0.mockError = nil }
        state.withLock { $0.mockLinkedProviders = [] }
        state.withLock { $0.mockAuthStateUsers = [] }
        state.withLock { $0.signInCallCount = 0 }
        state.withLock { $0.signUpCallCount = 0 }
        state.withLock { $0.signOutCallCount = 0 }
        state.withLock { $0.passwordResetCallCount = 0 }
        state.withLock { $0.updatePasswordCallCount = 0 }
        state.withLock { $0.oauthSignInCallCount = 0 }
        state.withLock { $0.reauthenticateCallCount = 0 }
        state.withLock { $0.revokeTokenCallCount = 0 }
        state.withLock { $0.lastAuthorizationCode = nil }
        state.withLock { $0.lastReauthenticateCredential = nil }
        state.withLock { $0.deleteAccountCallCount = 0 }
        state.withLock { $0.linkAccountCallCount = 0 }
        state.withLock { $0.unlinkProviderCallCount = 0 }
        state.withLock { $0.linkedProvidersCallCount = 0 }
        state.withLock { $0.authStateChangesCallCount = 0 }
        state.withLock { $0.sendEmailVerificationCallCount = 0 }
        state.withLock { $0.updateProfileCallCount = 0 }
    }

    func setMockError(_ error: Error?) {
        state.withLock { $0.mockError = error }
    }
}
