//
//  MockFeatureFlagProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import ARCFirebaseFeatureFlags
import Foundation
import os

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
final class MockFeatureFlagProvider: FeatureFlagProviding {
    private struct State {
        var flags: [String: any Sendable] = [:]
        var simulatedDelay: TimeInterval = 0.5
        var fetchCount: Int = 0
        var setDefaultsCount: Int = 0
        var configUpdateContinuation: AsyncStream<Void>.Continuation?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: Mock Configuration

    /// In-memory feature flag storage.
    var flags: [String: any Sendable] {
        get { state.withLock { $0.flags } }
        set { state.withLock { $0.flags = newValue } }
    }

    /// Simulated delay in seconds for fetch operations.
    var simulatedDelay: TimeInterval {
        get { state.withLock { $0.simulatedDelay } }
        set { state.withLock { $0.simulatedDelay = newValue } }
    }

    // MARK: Call Tracking

    /// Number of fetchAndActivate operations performed.
    var fetchCount: Int {
        state.withLock { $0.fetchCount }
    }

    /// Number of setDefaults operations performed.
    var setDefaultsCount: Int {
        state.withLock { $0.setDefaultsCount }
    }

    // MARK: Private State

    private var configUpdateContinuation: AsyncStream<Void>.Continuation? {
        get { state.withLock { $0.configUpdateContinuation } }
        set { state.withLock { $0.configUpdateContinuation = newValue } }
    }

    // MARK: Initialization

    /// Creates a mock provider with the given initial flags.
    ///
    /// - Parameter flags: Initial flag values. Defaults to a sample set.
    init(flags: [String: any Sendable] = MockFeatureFlagProvider.sampleFlags) {
        self.flags = flags
    }

    // MARK: FeatureFlagProviding Implementation

    func fetchAndActivate() async throws {
        state.withLock { $0.fetchCount += 1 }
        try await Task.sleep(for: .seconds(simulatedDelay))
        let flagCount = flags.count
        demoLogger.info("[Mock] Fetched and activated \(flagCount) feature flags")
    }

    func setDefaults(_ defaults: [String: any Sendable]) {
        state.withLock { $0.setDefaultsCount += 1 }
        for (key, value) in defaults where flags[key] == nil {
            state.withLock { $0.flags[key] = value }
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
        state.withLock { $0.configUpdateContinuation = continuation }
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
