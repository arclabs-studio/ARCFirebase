import Testing
@testable import ARCFirebaseAppCheck

@Suite("FirebaseAppCheckProvider Tests")
struct FirebaseAppCheckProviderTests {
    @Test("Mock provider configure sets isConfigured to true") func configure_setsIsConfigured() throws {
        let mock = makeSUT()

        #expect(mock.isConfigured == false)

        try mock.configure()

        #expect(mock.isConfigured == true)
        #expect(mock.configureCallCount == 1)
    }

    @Test("Mock provider configure throws when error is set") func configure_throwsOnError() throws {
        let mock = makeSUT()

        enum TestError: Error { case configFailed }
        mock.mockError = TestError.configFailed

        do {
            try mock.configure()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }

        #expect(mock.configureCallCount == 1)
        #expect(mock.isConfigured == false)
    }

    @Test("Mock provider returns token when configured") func getLimitedUseToken_returnsToken() async throws {
        let mock = makeSUT()
        mock.mockIsConfigured = true
        mock.mockToken = "test-token-123"

        let token = try await mock.getLimitedUseToken()

        #expect(token == "test-token-123")
        #expect(mock.getLimitedUseTokenCallCount == 1)
    }

    @Test("Mock provider throws when token error is set") func getLimitedUseToken_throwsOnError() async throws {
        let mock = makeSUT()
        mock.mockIsConfigured = true

        enum TestError: Error { case tokenFailed }
        mock.mockError = TestError.tokenFailed

        do {
            _ = try await mock.getLimitedUseToken()
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
            #expect(mock.getLimitedUseTokenCallCount == 1)
        }
    }

    @Test("Mock reset clears all state") func reset_clearsAllState() async throws {
        let mock = makeSUT()
        try mock.configure()
        _ = try await mock.getLimitedUseToken()

        mock.reset()

        #expect(mock.configureCallCount == 0)
        #expect(mock.getLimitedUseTokenCallCount == 0)
        #expect(mock.isConfigured == false)
        #expect(mock.mockToken == "mock-app-check-token")
    }

    // MARK: - AppCheckConfiguration Tests

    @Test("Default configuration is not debug") func defaultConfiguration_isNotDebug() {
        let config = AppCheckConfiguration.default

        #expect(config.isDebug == false)
    }

    @Test("Debug configuration is debug") func debugConfiguration_isDebug() {
        let config = AppCheckConfiguration.debug

        #expect(config.isDebug == true)
    }

    @Test("Custom configuration stores isDebug") func customConfiguration_storesIsDebug() {
        let config = AppCheckConfiguration(isDebug: true)

        #expect(config.isDebug == true)
    }

    @Test("Default init produces non-debug configuration") func defaultInit_isNotDebug() {
        let config = AppCheckConfiguration()

        #expect(config.isDebug == false)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockAppCheckProvider {
        MockAppCheckProvider()
    }
}
