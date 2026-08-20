//
//  FeatureFlagProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import Foundation

// MARK: - FeatureFlagProviding Protocol

/// Protocol defining feature flag and remote configuration capabilities.
///
/// Use this protocol for dependency injection to make your code testable.
///
/// ## Usage in Production
///
/// ```swift
/// class FeatureManager {
///     private let flags: FeatureFlagProviding
///
///     init(flags: FeatureFlagProviding) {
///         self.flags = flags
///     }
///
///     func isNewOnboardingEnabled() -> Bool {
///         flags.isEnabled("new_onboarding_v2")
///     }
///
///     func maxUploadSize() -> Int {
///         flags.int(forKey: "max_upload_size_mb", defaultValue: 10)
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// let mock = MockFeatureFlagProvider()
/// mock.mockFlags["new_onboarding_v2"] = true
/// mock.mockFlags["max_upload_size_mb"] = 50
///
/// let manager = FeatureManager(flags: mock)
/// #expect(manager.isNewOnboardingEnabled() == true)
/// #expect(manager.maxUploadSize() == 50)
/// ```
///
/// ## Topics
///
/// ### Fetching
/// - ``fetchAndActivate()``
/// - ``setDefaults(_:)``
///
/// ### Reading Values
/// - ``bool(forKey:defaultValue:)``
/// - ``string(forKey:defaultValue:)``
/// - ``int(forKey:defaultValue:)``
/// - ``double(forKey:defaultValue:)``
/// - ``data(forKey:defaultValue:)``
///
/// ### Real-Time Updates
/// - ``configUpdates()``
///
/// ### Implementations
/// - ``FirebaseFeatureFlagProvider``
public protocol FeatureFlagProviding: Sendable {
    /// Fetches remote config values and activates them.
    ///
    /// Call this at app launch or when you want to refresh configuration.
    ///
    /// - Throws: ``FirebaseError/fetchThrottled`` if requests are too frequent,
    ///           or ``FirebaseError/networkError(underlying:)`` on connection failure.
    func fetchAndActivate() async throws

    /// Sets default values for feature flags.
    ///
    /// Defaults are used when no server-side value has been fetched yet.
    ///
    /// - Parameter defaults: A dictionary of key-value pairs.
    func setDefaults(_ defaults: [String: any Sendable])

    /// Returns a Boolean value for the given key.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - defaultValue: The value to return if no remote value exists.
    /// - Returns: The remote value, or `defaultValue` if not available.
    func bool(forKey key: String, defaultValue: Bool) -> Bool

    /// Returns a String value for the given key.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - defaultValue: The value to return if no remote value exists.
    /// - Returns: The remote value, or `defaultValue` if not available.
    func string(forKey key: String, defaultValue: String) -> String

    /// Returns an Int value for the given key.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - defaultValue: The value to return if no remote value exists.
    /// - Returns: The remote value, or `defaultValue` if not available.
    func int(forKey key: String, defaultValue: Int) -> Int

    /// Returns a Double value for the given key.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - defaultValue: The value to return if no remote value exists.
    /// - Returns: The remote value, or `defaultValue` if not available.
    func double(forKey key: String, defaultValue: Double) -> Double

    /// Returns a Data value for the given key.
    ///
    /// - Parameters:
    ///   - key: The feature flag key.
    ///   - defaultValue: The value to return if no remote value exists.
    /// - Returns: The remote value, or `defaultValue` if not available.
    func data(forKey key: String, defaultValue: Data) -> Data

    /// Returns an async stream that yields whenever the remote config is updated.
    ///
    /// Use this to react to real-time configuration changes:
    ///
    /// ```swift
    /// for await _ in flags.configUpdates() {
    ///     // Refresh UI or re-read flag values
    /// }
    /// ```
    func configUpdates() -> AsyncStream<Void>
}

// MARK: - Convenience Defaults

extension FeatureFlagProviding {
    /// Returns whether the feature flag is enabled (defaults to `false`).
    ///
    /// Convenience for `bool(forKey: key, defaultValue: false)`.
    ///
    /// - Parameter key: The feature flag key.
    /// - Returns: `true` if the flag is enabled, `false` otherwise.
    public func isEnabled(_ key: String) -> Bool {
        bool(forKey: key, defaultValue: false)
    }

    /// Returns a Boolean value for the given key (defaults to `false`).
    public func bool(forKey key: String) -> Bool {
        bool(forKey: key, defaultValue: false)
    }

    /// Returns a String value for the given key (defaults to `""`).
    public func string(forKey key: String) -> String {
        string(forKey: key, defaultValue: "")
    }

    /// Returns an Int value for the given key (defaults to `0`).
    public func int(forKey key: String) -> Int {
        int(forKey: key, defaultValue: 0)
    }

    /// Returns a Double value for the given key (defaults to `0.0`).
    public func double(forKey key: String) -> Double {
        double(forKey: key, defaultValue: 0.0)
    }

    /// Returns a Data value for the given key (defaults to `Data()`).
    public func data(forKey key: String) -> Data {
        data(forKey: key, defaultValue: Data())
    }
}
