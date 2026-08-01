//
//  MockFeatureFlagProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import ARCFirebaseFeatureFlags
import Foundation

// MARK: - MockFeatureFlagProvider

/// A mock implementation of `FeatureFlagProviding` for SwiftUI previews and demo mode.
///
/// This provider simulates feature flags using an in-memory dictionary,
/// making it perfect for:
/// - SwiftUI previews
/// - Demo mode (no Firebase configuration)
/// - Unit testing
///
/// ## Example Usage
///
/// ```swift
/// let mock = MockFeatureFlagProvider()
/// mock.flags["new_onboarding"] = true
/// mock.flags["max_retries"] = 5
///
/// print(mock.isEnabled("new_onboarding")) // true
/// print(mock.int(forKey: "max_retries"))   // 5
/// ```
final class MockFeatureFlagProvider: FeatureFlagProviding, @unchecked Sendable {
    // MARK: Mock Configuration

    /// In-memory feature flag storage.
    var flags: [String: any Sendable]

    /// Simulated delay in seconds for fetch operations.
    var simulatedDelay: TimeInterval = 0.5

    // MARK: Call Tracking

    /// Number of fetchAndActivate operations performed.
    private(set) var fetchCount = 0

    /// Number of setDefaults operations performed.
    private(set) var setDefaultsCount = 0

    // MARK: Private State

    private var configUpdateContinuation: AsyncStream<Void>.Continuation?

    // MARK: Initialization

    /// Creates a mock provider with the given initial flags.
    ///
    /// - Parameter flags: Initial flag values. Defaults to a sample set.
    init(flags: [String: any Sendable] = MockFeatureFlagProvider.sampleFlags) {
        self.flags = flags
    }

    // MARK: FeatureFlagProviding Implementation

    func fetchAndActivate() async throws {
        fetchCount += 1
        try await Task.sleep(for: .seconds(simulatedDelay))
        print("🏳️ [Mock] Fetched and activated \(flags.count) feature flags")
    }

    func setDefaults(_ defaults: [String: any Sendable]) {
        setDefaultsCount += 1
        for (key, value) in defaults where flags[key] == nil {
            flags[key] = value
        }
    }

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        flags[key] as? Bool ?? defaultValue
    }

    func string(forKey key: String, defaultValue: String) -> String {
        flags[key] as? String ?? defaultValue
    }

    func int(forKey key: String, defaultValue: Int) -> Int {
        flags[key] as? Int ?? defaultValue
    }

    func double(forKey key: String, defaultValue: Double) -> Double {
        flags[key] as? Double ?? defaultValue
    }

    func data(forKey key: String, defaultValue: Data) -> Data {
        flags[key] as? Data ?? defaultValue
    }

    func configUpdates() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        configUpdateContinuation = continuation
        return stream
    }

    // MARK: Test Helpers

    /// Simulates a remote config update event.
    func simulateConfigUpdate() {
        configUpdateContinuation?.yield()
    }
}

// MARK: - Sample Data

extension MockFeatureFlagProvider {
    /// Sample feature flags for demo mode.
    static let sampleFlags: [String: any Sendable] = ["new_onboarding_v2": true,
                                                      "dark_mode_enabled": true,
                                                      "max_upload_size_mb": 25,
                                                      "api_timeout_seconds": 30.0,
                                                      "welcome_message": "Welcome to ARCFirebase Demo!",
                                                      "premium_features": false,
                                                      "maintenance_mode": false,
                                                      "min_app_version": "2.0.0"]

    /// Creates a shared mock provider for previews.
    static let preview = MockFeatureFlagProvider()
}
