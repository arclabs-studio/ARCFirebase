//
//  AppCheckConfiguration.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import Foundation

/// Configuration options for the App Check provider.
///
/// Use ``default`` for production and ``debug`` for development/testing.
///
/// ```swift
/// // Production
/// let provider = FirebaseAppCheckProvider(configuration: .default)
///
/// // Debug (simulator/testing)
/// let provider = FirebaseAppCheckProvider(configuration: .debug)
/// ```
public struct AppCheckConfiguration: Sendable {
    /// Whether to use the debug provider (for simulators and testing).
    ///
    /// When `true`, uses `AppCheckDebugProviderFactory` which allows
    /// testing without DeviceCheck hardware. Set a debug token in your
    /// Firebase Console App Check settings.
    public let isDebug: Bool

    /// Creates a custom App Check configuration.
    ///
    /// - Parameter isDebug: Pass `true` to use the debug provider.
    public init(isDebug: Bool = false) {
        self.isDebug = isDebug
    }

    /// Production configuration using DeviceCheck.
    public static let `default` = AppCheckConfiguration()

    /// Debug configuration for simulators and testing environments.
    ///
    /// - Note: Requires a debug token configured in Firebase Console.
    public static let debug = AppCheckConfiguration(isDebug: true)
}
