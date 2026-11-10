import Foundation
import os
@testable import ARCFirebaseAppCheck

/// Mock App Check provider for testing.
final class MockAppCheckProvider: AppCheckProviding {
    private struct State {
        var mockToken: String = "mock-app-check-token"
        var mockError: Error?
        var mockIsConfigured: Bool = false
        var configureCallCount: Int = 0
        var getLimitedUseTokenCallCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var mockToken: String {
        get { state.withLock { $0.mockToken } }
        set { state.withLock { $0.mockToken = newValue } }
    }

    var mockError: Error? {
        get { state.withLock { $0.mockError } }
        set { state.withLock { $0.mockError = newValue } }
    }

    var mockIsConfigured: Bool {
        get { state.withLock { $0.mockIsConfigured } }
        set { state.withLock { $0.mockIsConfigured = newValue } }
    }

    var configureCallCount: Int {
        state.withLock { $0.configureCallCount }
    }

    var getLimitedUseTokenCallCount: Int {
        state.withLock { $0.getLimitedUseTokenCallCount }
    }

    // MARK: - AppCheckProviding Implementation

    var isConfigured: Bool {
        mockIsConfigured
    }

    func configure() throws {
        state.withLock { $0.configureCallCount += 1 }
        if let error = mockError {
            throw error
        }
        state.withLock { $0.mockIsConfigured = true }
    }

    func getLimitedUseToken() async throws -> String {
        state.withLock { $0.getLimitedUseTokenCallCount += 1 }
        if let error = mockError {
            throw error
        }
        return mockToken
    }

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.mockToken = "mock-app-check-token" }
        state.withLock { $0.mockError = nil }
        state.withLock { $0.mockIsConfigured = false }
        state.withLock { $0.configureCallCount = 0 }
        state.withLock { $0.getLimitedUseTokenCallCount = 0 }
    }
}
