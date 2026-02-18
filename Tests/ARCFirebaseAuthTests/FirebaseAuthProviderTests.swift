import Testing
@testable import ARCFirebaseAuth

@Suite("FirebaseAuthProvider Tests")
struct FirebaseAuthProviderTests {
    @Test("Mock provider can authenticate user")
    func mockAuthenticationFlow() async throws {
        let mock = makeSUT()

        // Initially no user
        let isAuthenticatedBefore = await mock.isAuthenticated
        #expect(isAuthenticatedBefore == false)

        // Sign in
        let user = try await mock.signIn(email: "test@example.com", password: "password123")
        #expect(user.email == "test@example.com")
        #expect(mock.signInCallCount == 1)

        // Now authenticated
        let isAuthenticatedAfter = await mock.isAuthenticated
        #expect(isAuthenticatedAfter == true)

        let currentUser = await mock.currentUser
        #expect(currentUser?.id == user.id)
        #expect(currentUser?.email == "test@example.com")
    }

    @Test("Mock provider can sign up new user")
    func mockSignUpFlow() async throws {
        let mock = makeSUT()

        let user = try await mock.signUp(email: "newuser@example.com", password: "password123")
        #expect(user.email == "newuser@example.com")
        #expect(mock.signUpCallCount == 1)
        #expect(await mock.isAuthenticated == true)
    }

    @Test("Mock provider can sign out user")
    func mockSignOutFlow() async throws {
        let mock = makeSUT()

        // Sign in first
        _ = try await mock.signIn(email: "test@example.com", password: "password123")
        #expect(await mock.isAuthenticated == true)

        // Sign out
        try await mock.signOut()
        #expect(mock.signOutCallCount == 1)
        #expect(await mock.isAuthenticated == false)
        #expect(await mock.currentUser == nil)
    }

    @Test("Mock provider can send password reset")
    func mockPasswordResetFlow() async throws {
        let mock = makeSUT()

        try await mock.sendPasswordReset(email: "test@example.com")
        #expect(mock.passwordResetCallCount == 1)
    }

    @Test("Mock provider can update password")
    func mockUpdatePasswordFlow() async throws {
        let mock = makeSUT()

        // Sign in first
        _ = try await mock.signIn(email: "test@example.com", password: "oldpassword")

        // Update password
        try await mock.updatePassword("newpassword")
        #expect(mock.updatePasswordCallCount == 1)
    }

    @Test("Mock provider throws errors when configured")
    func mockErrorHandling() async throws {
        let mock = makeSUT()

        enum TestError: Error {
            case mockFailure
        }

        mock.reset()
        mock.setMockError(TestError.mockFailure)

        // Test sign in error
        do {
            _ = try await mock.signIn(email: "test@example.com", password: "password")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }

        // Test sign out error
        do {
            try await mock.signOut()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test("User model properties are accessible")
    func userModelProperties() {
        let user = User(id: "123", email: "test@example.com")

        #expect(user.id == "123")
        #expect(user.email == "test@example.com")
    }

    @Test("Mock reset clears all state")
    func mockResetFunctionality() async throws {
        let mock = makeSUT()

        // Perform some operations
        _ = try await mock.signIn(email: "test@example.com", password: "password")
        try await mock.sendPasswordReset(email: "test@example.com")

        #expect(mock.signInCallCount == 1)
        #expect(mock.passwordResetCallCount == 1)
        #expect(await mock.isAuthenticated == true)

        // Reset
        mock.reset()

        #expect(mock.signInCallCount == 0)
        #expect(mock.passwordResetCallCount == 0)
        #expect(await mock.isAuthenticated == false)
        #expect(await mock.currentUser == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockAuthProvider {
        MockAuthProvider()
    }
}
