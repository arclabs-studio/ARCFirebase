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
public final class FirebaseFeatureFlagProvider: FeatureFlagProviding {
    // MARK: - Properties

    private let store: FeatureFlagStore
    private let controller: RemoteConfigController
    private let subscriberChanges: AsyncStream<Void>.Continuation
    private let logger: ARCLogger

    // MARK: - Initialization

    /// Creates a Firebase feature flag provider with the given configuration.
    ///
    /// Values persisted by a previous launch are loaded in the background; until then, reads return the
    /// registered defaults.
    ///
    /// - Parameter configuration: The feature flag configuration to use. Defaults to
    /// ``FeatureFlagConfiguration/default``.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init(configuration: FeatureFlagConfiguration = .default) throws {
        try FirebaseManager.ensureConfigured()
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = configuration.minimumFetchInterval
        remoteConfig.configSettings = settings

        let logger = ARCLogger(subsystem: ARCFirebaseLogSubsystem.current, category: "FeatureFlags")
        let (changes, changesContinuation) = AsyncStream.makeStream(of: Void.self,
                                                                    bufferingPolicy: .bufferingNewest(1))
        let store = FeatureFlagStore { _ in changesContinuation.yield() }
        let controller = RemoteConfigController(remoteConfig: remoteConfig, store: store, logger: logger)

        self.store = store
        self.controller = controller
        subscriberChanges = changesContinuation
        self.logger = logger

        Task { [weak controller] in
            await controller?.loadPersistedConfig()
        }
        Task { [weak controller] in
            for await _ in changes {
                await controller?.reconcileListener()
            }
        }
        logger
            .info("FirebaseFeatureFlagProvider initialized with fetchInterval: \(configuration.minimumFetchInterval)s")
    }

    deinit {
        subscriberChanges.finish()
    }

    // MARK: - FeatureFlagProviding Implementation

    public func fetchAndActivate() async throws {
        logger.info("Fetching and activating remote config")

        do {
            let status = try await controller.fetchAndActivate()
            logger.info("Remote config fetch status: \(status)")
        } catch {
            logger.error("Remote config fetch failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func setDefaults(_ defaults: [String: any Sendable]) {
        logger.debug("Setting \(defaults.count) default values")
        store.replaceDefaults(defaults)
    }

    public func bool(forKey key: String, defaultValue: Bool) -> Bool {
        store.snapshot.bool(forKey: key, defaultValue: defaultValue)
    }

    public func string(forKey key: String, defaultValue: String) -> String {
        store.snapshot.string(forKey: key, defaultValue: defaultValue)
    }

    public func int(forKey key: String, defaultValue: Int) -> Int {
        store.snapshot.int(forKey: key, defaultValue: defaultValue)
    }

    public func double(forKey key: String, defaultValue: Double) -> Double {
        store.snapshot.double(forKey: key, defaultValue: defaultValue)
    }

    public func data(forKey key: String, defaultValue: Data) -> Data {
        store.snapshot.data(forKey: key, defaultValue: defaultValue)
    }

    /// Returns a stream that yields each time new remote values become active: after the persisted config
    /// loads, after ``fetchAndActivate()``, and after a real-time update is activated.
    ///
    /// The real-time listener stays open only while at least one stream is alive.
    public func configUpdates() -> AsyncStream<Void> {
        store.updates()
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
