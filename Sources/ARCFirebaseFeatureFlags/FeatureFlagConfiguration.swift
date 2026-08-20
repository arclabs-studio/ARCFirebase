//
//  FeatureFlagConfiguration.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import Foundation

// MARK: - FeatureFlagConfiguration

/// Configuration options for feature flag providers.
///
/// Use this struct to customize Remote Config behavior such as fetch intervals.
///
/// ## Usage
///
/// ```swift
/// // Use development configuration (no fetch throttle)
/// let provider = try FirebaseFeatureFlagProvider(
///     configuration: .development
/// )
///
/// // Use production configuration (12-hour cache)
/// let provider = try FirebaseFeatureFlagProvider(
///     configuration: .production
/// )
/// ```
///
/// ## Topics
///
/// ### Properties
/// - ``minimumFetchInterval``
///
/// ### Presets
/// - ``default``
/// - ``development``
/// - ``production``
public struct FeatureFlagConfiguration: Sendable {
    /// Minimum interval in seconds between Remote Config fetches.
    ///
    /// Firebase throttles requests that exceed this interval.
    /// Use ``development`` preset (0 seconds) during development
    /// and ``production`` preset (12 hours) for release builds.
    ///
    /// Default: 43,200 seconds (12 hours)
    public let minimumFetchInterval: TimeInterval

    /// Creates a feature flag configuration with custom settings.
    ///
    /// - Parameter minimumFetchInterval: Minimum seconds between fetches. Default is 12 hours.
    public init(minimumFetchInterval: TimeInterval = 43200) {
        self.minimumFetchInterval = minimumFetchInterval
    }

    /// Default configuration with 12-hour fetch interval.
    public static let `default` = FeatureFlagConfiguration()

    /// Development configuration with no fetch throttle.
    ///
    /// - Important: Do not use in production. Firebase may throttle your app
    ///              if too many requests are made in a short period.
    public static let development = FeatureFlagConfiguration(minimumFetchInterval: 0)

    /// Production configuration with 12-hour fetch interval.
    public static let production = FeatureFlagConfiguration(minimumFetchInterval: 43200)
}
