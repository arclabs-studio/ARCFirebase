import Testing
@testable import ARCFirebaseAuth

@Suite("FirebaseAuthProvider Tests") struct FirebaseAuthProviderTests {
    @Test("Mock provider can authenticate user") func mockAuthenticationFlow() async throws {
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

    @Test("Mock provider can sign up new user") func mockSignUpFlow() async throws {
        let mock = makeSUT()

        let user = try await mock.signUp(email: "newuser@example.com", password: "password123")
        #expect(user.email == "newuser@example.com")
        #expect(mock.signUpCallCount == 1)
        #expect(await mock.isAuthenticated == true)
    }

    @Test("Mock provider can sign out user") func mockSignOutFlow() async throws {
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

    @Test("Mock provider can send password reset") func mockPasswordResetFlow() async throws {
        let mock = makeSUT()

        try await mock.sendPasswordReset(email: "test@example.com")
        #expect(mock.passwordResetCallCount == 1)
    }

    @Test("Mock provider can update password") func mockUpdatePasswordFlow() async throws {
        let mock = makeSUT()

        // Sign in first
        _ = try await mock.signIn(email: "test@example.com", password: "oldpassword")

        // Update password
        try await mock.updatePassword("newpassword")
        #expect(mock.updatePasswordCallCount == 1)
    }

    @Test("Mock provider throws errors when configured") func mockErrorHandling() async throws {
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

    @Test("User model properties are accessible") func userModelProperties() {
        let user = User(id: "123", email: "test@example.com")

        #expect(user.id == "123")
        #expect(user.email == "test@example.com")
    }

    @Test("Mock reset clears all state") func mockResetFunctionality() async throws {
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

    // MARK: - User Model Tests

    @Test("User has default nil providerID and empty linkedProviderIDs") func userDefaultProviderProperties() {
        // Given / When
        let user = User(id: "123", email: "test@example.com")

        // Then
        #expect(user.providerID == nil)
        #expect(user.linkedProviderIDs.isEmpty)
    }

    @Test("User stores provider info correctly") func userProviderProperties() {
        // Given / When
        let user = User(id: "123",
                        email: "test@example.com",
                        providerID: "google.com",
                        linkedProviderIDs: ["google.com", "apple.com"])

        // Then
        #expect(user.providerID == "google.com")
        #expect(user.linkedProviderIDs == ["google.com", "apple.com"])
    }

    @Test("User conforms to Equatable") func userEquatable() {
        // Given
        let user1 = User(id: "123", email: "test@example.com", providerID: "google.com")
        let user2 = User(id: "123", email: "test@example.com", providerID: "google.com")
        let user3 = User(id: "456", email: "other@example.com")

        // Then
        #expect(user1 == user2)
        #expect(user1 != user3)
    }

    @Test("User description includes provider") func userDescription() {
        // Given
        let user = User(id: "123", email: "test@example.com", providerID: "google.com")

        // Then
        #expect(user.description.contains("google.com"))
        #expect(user.description.contains("123"))
    }

    // MARK: - OAuth Sign-In Tests

    @Test("OAuth sign in returns user with provider info") func oauthSignIn() async throws {
        // Given
        let mock = makeSUT()
        let credential = OAuthCredentialData(providerID: "google.com",
                                             idToken: "mock-id-token",
                                             accessToken: "mock-access-token")

        // When
        let user = try await mock.signIn(with: credential)

        // Then
        #expect(user.providerID == "google.com")
        #expect(user.linkedProviderIDs.contains("google.com"))
        #expect(mock.oauthSignInCallCount == 1)
    }

    @Test("OAuth sign in returns pre-configured mock user") func oauthSignInWithMockUser() async throws {
        // Given
        let mock = makeSUT()
        let expectedUser = User(id: "preset-id", email: "preset@example.com", providerID: "apple.com")
        mock.mockUser = expectedUser

        let credential = OAuthCredentialData(providerID: "apple.com", idToken: "token")

        // When
        let user = try await mock.signIn(with: credential)

        // Then
        #expect(user == expectedUser)
    }

    @Test("OAuth sign in throws error when configured") func oauthSignInError() async throws {
        // Given
        let mock = makeSUT()

        enum TestError: Error { case oauthFailed }
        mock.setMockError(TestError.oauthFailed)

        let credential = OAuthCredentialData(providerID: "google.com", idToken: "token")

        // When / Then
        do {
            _ = try await mock.signIn(with: credential)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
            #expect(mock.oauthSignInCallCount == 1)
        }
    }

    // MARK: - Auth State Changes Tests

    @Test("Auth state changes stream emits correct sequence") func authStateChanges() async {
        // Given
        let mock = makeSUT()
        let user = User(id: "123", email: "test@example.com")
        mock.mockAuthStateUsers = [nil, user, nil]

        // When
        var emittedUsers: [User?] = []
        for await user in mock.authStateChanges() {
            emittedUsers.append(user)
        }

        // Then
        #expect(emittedUsers.count == 3)
        #expect(emittedUsers[0] == nil)
        #expect(emittedUsers[1] == user)
        #expect(emittedUsers[2] == nil)
        #expect(mock.authStateChangesCallCount == 1)
    }

    @Test("Auth state changes stream handles empty sequence") func authStateChangesEmpty() async {
        // Given
        let mock = makeSUT()
        mock.mockAuthStateUsers = []

        // When
        var emittedUsers: [User?] = []
        for await user in mock.authStateChanges() {
            emittedUsers.append(user)
        }

        // Then
        #expect(emittedUsers.isEmpty)
    }

    // MARK: - Delete Account Tests

    @Test("Delete account succeeds and clears user") func deleteAccount() async throws {
        // Given
        let mock = makeSUT()
        mock.mockUser = User(id: "123", email: "test@example.com")

        // When
        try await mock.deleteAccount()

        // Then
        #expect(mock.deleteAccountCallCount == 1)
        #expect(await mock.currentUser == nil)
    }

    @Test("Delete account throws error when configured") func deleteAccountError() async throws {
        // Given
        let mock = makeSUT()

        enum TestError: Error { case deleteFailed }
        mock.setMockError(TestError.deleteFailed)

        // When / Then
        do {
            try await mock.deleteAccount()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
            #expect(mock.deleteAccountCallCount == 1)
        }
    }

    // MARK: - Provider Linking Tests

    @Test("Link account adds provider to user") func linkAccount() async throws {
        // Given
        let mock = makeSUT()
        mock.mockUser = User(id: "123",
                             email: "test@example.com",
                             providerID: "password",
                             linkedProviderIDs: ["password"])
        let credential = OAuthCredentialData(providerID: "google.com", idToken: "token")

        // When
        let updatedUser = try await mock.linkAccount(with: credential)

        // Then
        #expect(mock.linkAccountCallCount == 1)
        #expect(updatedUser.linkedProviderIDs.contains("google.com"))
        #expect(updatedUser.linkedProviderIDs.contains("password"))
    }

    @Test("Unlink provider removes provider from user") func unlinkProvider() async throws {
        // Given
        let mock = makeSUT()
        mock.mockUser = User(id: "123",
                             email: "test@example.com",
                             providerID: "password",
                             linkedProviderIDs: ["password", "google.com"])

        // When
        let updatedUser = try await mock.unlinkProvider("google.com")

        // Then
        #expect(mock.unlinkProviderCallCount == 1)
        #expect(!updatedUser.linkedProviderIDs.contains("google.com"))
        #expect(updatedUser.linkedProviderIDs.contains("password"))
    }

    @Test("Linked providers returns configured list") func linkedProviders() async {
        // Given
        let mock = makeSUT()
        mock.mockLinkedProviders = ["password", "google.com", "apple.com"]

        // When
        let providers = await mock.linkedProviders()

        // Then
        #expect(providers == ["password", "google.com", "apple.com"])
        #expect(mock.linkedProvidersCallCount == 1)
    }

    @Test("Linked providers returns empty when no providers configured") func linkedProvidersEmpty() async {
        // Given
        let mock = makeSUT()

        // When
        let providers = await mock.linkedProviders()

        // Then
        #expect(providers.isEmpty)
    }

    // MARK: - Reset Tests

    @Test("Reset clears all new call counts and state") func resetClearsNewState() async throws {
        // Given
        let mock = makeSUT()
        mock.mockUser = User(id: "123", email: "test@example.com")
        mock.mockLinkedProviders = ["google.com"]
        mock.mockAuthStateUsers = [nil]

        _ = try await mock.signIn(with: OAuthCredentialData(providerID: "google.com"))
        try await mock.deleteAccount()
        mock.mockUser = User(id: "456", email: "test@example.com")
        _ = try await mock.linkAccount(with: OAuthCredentialData(providerID: "apple.com"))
        _ = try await mock.unlinkProvider("apple.com")
        _ = await mock.linkedProviders()
        _ = mock.authStateChanges()

        // When
        mock.reset()

        // Then
        #expect(mock.oauthSignInCallCount == 0)
        #expect(mock.deleteAccountCallCount == 0)
        #expect(mock.linkAccountCallCount == 0)
        #expect(mock.unlinkProviderCallCount == 0)
        #expect(mock.linkedProvidersCallCount == 0)
        #expect(mock.authStateChangesCallCount == 0)
        #expect(mock.mockLinkedProviders.isEmpty)
        #expect(mock.mockAuthStateUsers.isEmpty)
        #expect(await mock.currentUser == nil)
    }

    // MARK: - OAuthCredentialData Tests

    @Test("OAuthCredentialData stores all properties") func oauthCredentialProperties() {
        // Given / When
        let credential = OAuthCredentialData(providerID: "google.com",
                                             idToken: "id-token",
                                             accessToken: "access-token",
                                             rawNonce: "nonce")

        // Then
        #expect(credential.providerID == "google.com")
        #expect(credential.idToken == "id-token")
        #expect(credential.accessToken == "access-token")
        #expect(credential.rawNonce == "nonce")
    }

    @Test("OAuthCredentialData has sensible defaults") func oauthCredentialDefaults() {
        // Given / When
        let credential = OAuthCredentialData(providerID: "apple.com")

        // Then
        #expect(credential.providerID == "apple.com")
        #expect(credential.idToken == nil)
        #expect(credential.accessToken == nil)
        #expect(credential.rawNonce == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockAuthProvider {
        MockAuthProvider()
    }
}
