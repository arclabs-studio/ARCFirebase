//
//  FirebaseFeatureFlagProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseRemoteConfig
import Foundation

/// Firebase implementation of ``FeatureFlagProviding``.
///
/// This is the production feature flag provider that uses Firebase Remote Config.
///
/// ## Initialization
///
/// ```swift
/// // Create with default configuration (12-hour cache)
/// let flags = try FirebaseFeatureFlagProvider()
///
/// // Create with development configuration (no cache)
/// let flags = try FirebaseFeatureFlagProvider(
///     configuration: .development
/// )
///
/// // Or use the convenience default
/// let flags = FirebaseFeatureFlagProvider.live
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(configuration:)``
/// - ``create(configuration:)``
/// - ``create()``
/// - ``live``
public final class FirebaseFeatureFlagProvider: FeatureFlagProviding, @unchecked Sendable {
    // MARK: - Properties

    private let remoteConfig: RemoteConfig
    private let logger: ARCLogger

    // MARK: - Initialization

    /// Creates a Firebase feature flag provider with the given configuration.
    ///
    /// - Parameter configuration: The feature flag configuration to use. Defaults to
    /// ``FeatureFlagConfiguration/default``.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init(configuration: FeatureFlagConfiguration = .default) throws {
        try FirebaseManager.ensureConfigured()
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = configuration.minimumFetchInterval
        remoteConfig.configSettings = settings
        logger = ARCLogger(subsystem: "com.arclabs-studio.arcfirebase", category: "FeatureFlags")
        logger
            .info("FirebaseFeatureFlagProvider initialized with fetchInterval: \(configuration.minimumFetchInterval)s")
    }

    // MARK: - FeatureFlagProviding Implementation

    public func fetchAndActivate() async throws {
        logger.info("Fetching and activating remote config")

        do {
            let status = try await remoteConfig.fetchAndActivate()
            logger.info("Remote config fetch status: \(status)")
        } catch {
            logger.error("Remote config fetch failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func setDefaults(_ defaults: [String: any Sendable]) {
        logger.debug("Setting \(defaults.count) default values")
        remoteConfig.setDefaults(defaults as? [String: NSObject])
    }

    public func bool(forKey key: String, defaultValue: Bool) -> Bool {
        let configValue = remoteConfig.configValue(forKey: key)
        guard configValue.source != .static else {
            return defaultValue
        }
        return configValue.boolValue
    }

    public func string(forKey key: String, defaultValue: String) -> String {
        let configValue = remoteConfig.configValue(forKey: key)
        guard configValue.source != .static else {
            return defaultValue
        }
        return configValue.stringValue
    }

    public func int(forKey key: String, defaultValue: Int) -> Int {
        let configValue = remoteConfig.configValue(forKey: key)
        guard configValue.source != .static else {
            return defaultValue
        }
        return configValue.numberValue.intValue
    }

    public func double(forKey key: String, defaultValue: Double) -> Double {
        let configValue = remoteConfig.configValue(forKey: key)
        guard configValue.source != .static else {
            return defaultValue
        }
        return configValue.numberValue.doubleValue
    }

    public func data(forKey key: String, defaultValue: Data) -> Data {
        let configValue = remoteConfig.configValue(forKey: key)
        guard configValue.source != .static else {
            return defaultValue
        }
        return configValue.dataValue
    }

    public func configUpdates() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        let logger = logger

        let registration = remoteConfig.addOnConfigUpdateListener { [weak remoteConfig] configUpdate, error in
            if let error {
                logger.error("Config update error: \(error.localizedDescription)")
                return
            }

            guard configUpdate != nil else { return }

            remoteConfig?.activate { _, activateError in
                if let activateError {
                    logger.error("Config activation error: \(activateError.localizedDescription)")
                    return
                }
                logger.info("Config updated and activated")
                continuation.yield()
            }
        }

        continuation.onTermination = { _ in
            registration.remove()
        }

        return stream
    }
}

// MARK: - Factory Methods

extension FirebaseFeatureFlagProvider {
    /// Creates a new instance with the given configuration and explicit error handling.
    ///
    /// - Parameter configuration: The feature flag configuration to use.
    /// - Returns: A configured ``FirebaseFeatureFlagProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create(configuration: FeatureFlagConfiguration = .default) throws
    -> FirebaseFeatureFlagProvider {
        try FirebaseFeatureFlagProvider(configuration: configuration)
    }

    /// Creates a new instance with default configuration and explicit error handling.
    ///
    /// - Returns: A configured ``FirebaseFeatureFlagProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create() throws -> FirebaseFeatureFlagProvider {
        try FirebaseFeatureFlagProvider()
    }

    /// Default live instance for production use.
    ///
    /// - Important: This will crash if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first.
    public static var live: FirebaseFeatureFlagProvider {
        do {
            return try create()
        } catch {
            fatalError("""
            FirebaseFeatureFlagProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(error.localizedDescription)
            """)
        }
    }
}
