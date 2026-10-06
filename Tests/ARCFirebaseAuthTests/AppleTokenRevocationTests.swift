import Testing
@testable import ARCFirebaseAuth

/// Covers the re-authentication and Apple token revocation added for in-app account
/// deletion. Kept apart from `FirebaseAuthProviderTests` so neither file outgrows the
/// length limits.
@Suite("Apple Token Revocation Tests")
struct AppleTokenRevocationTests {
    // MARK: - Revocation

    @Test("revokeToken forwards the authorization code") func revokeTokenForwardsCode() async throws {
        // Given
        let mock = makeSUT()
        mock.mockUser = User(id: "123", email: "test@example.com")

        // When
        try await mock.revokeToken(authorizationCode: "auth-code-abc")

        // Then
        #expect(mock.revokeTokenCallCount == 1)
        #expect(mock.lastAuthorizationCode == "auth-code-abc")
    }

    @Test("revokeToken propagates the provider error") func revokeTokenError() async throws {
        // Given
        let mock = makeSUT()

        enum TestError: Error { case codeFlowNotEnabled }
        mock.setMockError(TestError.codeFlowNotEnabled)

        // When/Then
        do {
            try await mock.revokeToken(authorizationCode: "stale-code")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
            #expect(mock.revokeTokenCallCount == 1)
        }
    }

    // MARK: - Re-authentication

    @Test("reauthenticate returns the user and records the credential") func reauthenticateReturnsUser() async throws {
        // Given
        let mock = makeSUT()
        let credential = OAuthCredentialData(providerID: "apple.com",
                                             idToken: "id-token",
                                             rawNonce: "nonce",
                                             authorizationCode: "auth-code")

        // When
        let user = try await mock.reauthenticate(with: credential)

        // Then
        #expect(mock.reauthenticateCallCount == 1)
        #expect(user.providerID == "apple.com")
        #expect(mock.lastReauthenticateCredential?.authorizationCode == "auth-code")
    }

    @Test("reauthenticate propagates the provider error") func reauthenticateError() async throws {
        // Given
        let mock = makeSUT()

        enum TestError: Error { case requiresRecentLogin }
        mock.setMockError(TestError.requiresRecentLogin)

        // When/Then
        do {
            _ = try await mock.reauthenticate(with: OAuthCredentialData(providerID: "apple.com"))
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
            #expect(mock.reauthenticateCallCount == 1)
        }
    }

    // MARK: - OAuthCredentialData

    @Test("OAuthCredentialData carries the authorization code") func credentialCarriesAuthorizationCode() {
        // Given/When
        let withCode = OAuthCredentialData(providerID: "apple.com",
                                           idToken: "id-token",
                                           rawNonce: "nonce",
                                           authorizationCode: "auth-code")
        let withoutCode = OAuthCredentialData(providerID: "google.com", idToken: "id-token")

        // Then — optional, so existing Google call sites keep compiling untouched
        #expect(withCode.authorizationCode == "auth-code")
        #expect(withoutCode.authorizationCode == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockAuthProvider {
        MockAuthProvider()
    }
}
