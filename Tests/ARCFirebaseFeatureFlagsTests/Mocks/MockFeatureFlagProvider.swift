import Foundation
@testable import ARCFirebaseFeatureFlags

/// Mock feature flag provider for testing.
final class MockFeatureFlagProvider: FeatureFlagProviding, @unchecked Sendable {
    // MARK: - Mock State

    var mockFlags: [String: any Sendable] = [:]
    var mockError: Error?
    private(set) var fetchAndActivateCallCount = 0
    private(set) var setDefaultsCallCount = 0
    private(set) var lastSetDefaults: [String: any Sendable]?

    private var configUpdateContinuation: AsyncStream<Void>.Continuation?

    // MARK: - FeatureFlagProviding Implementation

    func fetchAndActivate() async throws {
        fetchAndActivateCallCount += 1

        if let error = mockError {
            throw error
        }
    }

    func setDefaults(_ defaults: [String: any Sendable]) {
        setDefaultsCallCount += 1
        lastSetDefaults = defaults

        // Merge defaults (don't overwrite existing mock values)
        for (key, value) in defaults where mockFlags[key] == nil {
            mockFlags[key] = value
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
        configUpdateContinuation = continuation
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
        mockFlags.removeAll()
        mockError = nil
        fetchAndActivateCallCount = 0
        setDefaultsCallCount = 0
        lastSetDefaults = nil
        configUpdateContinuation = nil
    }
}

// MARK: - Mock Errors

enum MockFeatureFlagError: Error {
    case fetchFailed
    case throttled
}
