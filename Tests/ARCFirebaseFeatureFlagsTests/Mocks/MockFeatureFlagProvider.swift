import Foundation
import os
@testable import ARCFirebaseFeatureFlags

/// Mock feature flag provider for testing.
final class MockFeatureFlagProvider: FeatureFlagProviding {
    private struct State {
        var mockFlags: [String: any Sendable] = [:]
        var mockError: Error?
        var fetchAndActivateCallCount: Int = 0
        var setDefaultsCallCount: Int = 0
        var lastSetDefaults: [String: any Sendable]?
        var configUpdateContinuation: AsyncStream<Void>.Continuation?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var mockFlags: [String: any Sendable] {
        get { state.withLock { $0.mockFlags } }
        set { state.withLock { $0.mockFlags = newValue } }
    }

    var mockError: Error? {
        get { state.withLock { $0.mockError } }
        set { state.withLock { $0.mockError = newValue } }
    }

    var fetchAndActivateCallCount: Int {
        state.withLock { $0.fetchAndActivateCallCount }
    }

    var setDefaultsCallCount: Int {
        state.withLock { $0.setDefaultsCallCount }
    }

    var lastSetDefaults: [String: any Sendable]? {
        state.withLock { $0.lastSetDefaults }
    }

    private var configUpdateContinuation: AsyncStream<Void>.Continuation? {
        get { state.withLock { $0.configUpdateContinuation } }
        set { state.withLock { $0.configUpdateContinuation = newValue } }
    }

    // MARK: - FeatureFlagProviding Implementation

    func fetchAndActivate() async throws {
        state.withLock { $0.fetchAndActivateCallCount += 1 }

        if let error = mockError {
            throw error
        }
    }

    func setDefaults(_ defaults: [String: any Sendable]) {
        state.withLock { $0.setDefaultsCallCount += 1 }
        state.withLock { $0.lastSetDefaults = defaults }

        // Merge defaults (don't overwrite existing mock values)
        for (key, value) in defaults where mockFlags[key] == nil {
            state.withLock { $0.mockFlags[key] = value }
        }
    }

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        mockFlags[key] as? Bool ?? defaultValue
    }

    func string(forKey key: String, defaultValue: String) -> String {
        mockFlags[key] as? String ?? defaultValue
    }

    func int(forKey key: String, defaultValue: Int) -> Int {
        mockFlags[key] as? Int ?? defaultValue
    }

    func double(forKey key: String, defaultValue: Double) -> Double {
        mockFlags[key] as? Double ?? defaultValue
    }

    func data(forKey key: String, defaultValue: Data) -> Data {
        mockFlags[key] as? Data ?? defaultValue
    }

    func configUpdates() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        state.withLock { $0.configUpdateContinuation = continuation }
        return stream
    }

    // MARK: - Test Helpers

    /// Simulates a remote config update event.
    func simulateConfigUpdate() {
        configUpdateContinuation?.yield()
    }

    /// Finishes the config update stream.
    func finishConfigUpdates() {
        configUpdateContinuation?.finish()
    }

    func reset() {
        state.withLock { $0.mockFlags.removeAll() }
        state.withLock { $0.mockError = nil }
        state.withLock { $0.fetchAndActivateCallCount = 0 }
        state.withLock { $0.setDefaultsCallCount = 0 }
        state.withLock { $0.lastSetDefaults = nil }
        state.withLock { $0.configUpdateContinuation = nil }
    }
}

// MARK: - Mock Errors

enum MockFeatureFlagError: Error {
    case fetchFailed
    case throttled
}
