import Foundation
@testable import ARCFirebaseAppCheck

/// Mock App Check provider for testing.
final class MockAppCheckProvider: AppCheckProviding, @unchecked Sendable {
    // MARK: - Mock State

    var mockToken: String = "mock-app-check-token"
    var mockError: Error?
    var mockIsConfigured = false

    private(set) var configureCallCount = 0
    private(set) var getLimitedUseTokenCallCount = 0

    // MARK: - AppCheckProviding Implementation

    var isConfigured: Bool {
        mockIsConfigured
    }

    func configure() throws {
        configureCallCount += 1
        if let error = mockError {
            throw error
        }
        mockIsConfigured = true
    }

    func getLimitedUseToken() async throws -> String {
        getLimitedUseTokenCallCount += 1
        if let error = mockError {
            throw error
        }
        return mockToken
    }

    // MARK: - Test Helpers

    func reset() {
        mockToken = "mock-app-check-token"
        mockError = nil
        mockIsConfigured = false
        configureCallCount = 0
        getLimitedUseTokenCallCount = 0
    }
}
