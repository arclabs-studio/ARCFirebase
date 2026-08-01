import Foundation
@testable import ARCFirebaseAuth

/// Mock authentication provider for testing.
final class MockAuthProvider: AuthProviding, @unchecked Sendable {
    // MARK: - Mock State

    var mockUser: User?
    var mockError: Error?
    var mockLinkedProviders: [String] = []
    var mockAuthStateUsers: [User?] = []

    private(set) var signInCallCount = 0
    private(set) var signUpCallCount = 0
    private(set) var signOutCallCount = 0
    private(set) var passwordResetCallCount = 0
    private(set) var updatePasswordCallCount = 0
    private(set) var oauthSignInCallCount = 0
    private(set) var deleteAccountCallCount = 0
    private(set) var linkAccountCallCount = 0
    private(set) var unlinkProviderCallCount = 0
    private(set) var linkedProvidersCallCount = 0
    private(set) var authStateChangesCallCount = 0
    private(set) var sendEmailVerificationCallCount = 0
    private(set) var updateProfileCallCount = 0

    // MARK: - AuthProviding Implementation

    var currentUser: User? {
        get async { mockUser }
    }

    var isAuthenticated: Bool {
        get async { mockUser != nil }
    }

    func signIn(email: String, password _: String) async throws -> User {
        signInCallCount += 1

        if let error = mockError {
            throw error
        }

        if let user = mockUser {
            return user
        }

        // Create a default mock user
        let user = User(id: "mock-user-id", email: email)
        mockUser = user
        return user
    }

    func signUp(email: String, password _: String) async throws -> User {
        signUpCallCount += 1

        if let error = mockError {
            throw error
        }

        let user = User(id: "new-user-\(UUID().uuidString)", email: email)
        mockUser = user
        return user
    }

    func signOut() async throws {
        signOutCallCount += 1

        if let error = mockError {
            throw error
        }

        mockUser = nil
    }

    func sendPasswordReset(email _: String) async throws {
        passwordResetCallCount += 1

        if let error = mockError {
            throw error
        }
    }

    func updatePassword(_: String) async throws {
        updatePasswordCallCount += 1

        if let error = mockError {
            throw error
        }
    }

    func signIn(with credential: OAuthCredentialData) async throws -> User {
        oauthSignInCallCount += 1

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
        mockUser = user
        return user
    }

    func authStateChanges() -> AsyncStream<User?> {
        authStateChangesCallCount += 1

        let users = mockAuthStateUsers
        return AsyncStream { continuation in
            for user in users {
                continuation.yield(user)
            }
            continuation.finish()
        }
    }

    func deleteAccount() async throws {
        deleteAccountCallCount += 1

        if let error = mockError {
            throw error
        }

        mockUser = nil
    }

    func linkAccount(with credential: OAuthCredentialData) async throws -> User {
        linkAccountCallCount += 1

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
        mockUser = user
        return user
    }

    func unlinkProvider(_ providerID: String) async throws -> User {
        unlinkProviderCallCount += 1

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
        mockUser = user
        return user
    }

    func linkedProviders() async -> [String] {
        linkedProvidersCallCount += 1
        return mockLinkedProviders
    }

    func sendEmailVerification() async throws {
        sendEmailVerificationCallCount += 1

        if let error = mockError {
            throw error
        }
    }

    func updateProfile(displayName: String?, photoURL _: URL?) async throws {
        updateProfileCallCount += 1
        if let error = mockError { throw error }
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
            mockUser = user
        }
    }

    // MARK: - Test Helpers

    func reset() {
        mockUser = nil
        mockError = nil
        mockLinkedProviders = []
        mockAuthStateUsers = []
        signInCallCount = 0
        signUpCallCount = 0
        signOutCallCount = 0
        passwordResetCallCount = 0
        updatePasswordCallCount = 0
        oauthSignInCallCount = 0
        deleteAccountCallCount = 0
        linkAccountCallCount = 0
        unlinkProviderCallCount = 0
        linkedProvidersCallCount = 0
        authStateChangesCallCount = 0
        sendEmailVerificationCallCount = 0
        updateProfileCallCount = 0
    }

    func setMockError(_ error: Error?) {
        mockError = error
    }
}
