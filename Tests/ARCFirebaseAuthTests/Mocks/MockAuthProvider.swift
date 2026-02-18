import Foundation
@testable import ARCFirebaseAuth

/// Mock authentication provider for testing.
final class MockAuthProvider: AuthProviding, @unchecked Sendable {
    // MARK: - Mock State

    var mockUser: User?
    var mockError: Error?
    private(set) var signInCallCount = 0
    private(set) var signUpCallCount = 0
    private(set) var signOutCallCount = 0
    private(set) var passwordResetCallCount = 0
    private(set) var updatePasswordCallCount = 0

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

    // MARK: - Test Helpers

    func reset() {
        mockUser = nil
        mockError = nil
        signInCallCount = 0
        signUpCallCount = 0
        signOutCallCount = 0
        passwordResetCallCount = 0
        updatePasswordCallCount = 0
    }

    func setMockError(_ error: Error?) {
        mockError = error
    }
}
