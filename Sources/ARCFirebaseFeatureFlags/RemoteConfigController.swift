//
//  RemoteConfigController.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-05.
//

import ARCLogger
import FirebaseRemoteConfig
import Foundation

// MARK: - RemoteConfigController

/// Sole owner of the non-`Sendable` `RemoteConfig` instance.
///
/// Firebase recommends isolating `RemoteConfig` behind an actor under Swift concurrency
/// (firebase-ios-sdk discussion #15924). Every interaction with it happens here; the results leave the
/// actor only as `Sendable` `[String: Data]` values published into the ``FeatureFlagStore``.
actor RemoteConfigController {
    // MARK: Properties

    private let remoteConfig: RemoteConfig
    private let store: FeatureFlagStore
    private let logger: ARCLogger
    private var registration: ConfigUpdateListenerRegistration?

    // MARK: Initialization

    init(remoteConfig: sending RemoteConfig, store: FeatureFlagStore, logger: ARCLogger) {
        self.remoteConfig = remoteConfig
        self.store = store
        self.logger = logger
    }

    /// `RemoteConfig` is a process-wide singleton that outlives this actor, so an open listener must be
    /// removed here or its backend connection stays open for the rest of the process.
    deinit {
        registration?.remove()
    }

    // MARK: Lifecycle

    /// Waits for the config persisted by a previous launch to load, then publishes it.
    ///
    /// Remote Config reads its on-disk config asynchronously at startup; until this completes, it reports
    /// no remote values.
    func loadPersistedConfig() async {
        do {
            try await remoteConfig.ensureInitialized()
            publishActiveValues()
        } catch {
            logger.error("Remote config initialization failed: \(error.localizedDescription)")
        }
    }

    func fetchAndActivate() async throws -> RemoteConfigFetchAndActivateStatus {
        let status = try await remoteConfig.fetchAndActivate()
        publishActiveValues()
        return status
    }

    /// Opens the real-time listener while the store has subscribers and closes it when it has none.
    ///
    /// Reads the store's current state instead of trusting the triggering event, so out-of-order
    /// notifications still converge on the right state.
    func reconcileListener() {
        switch (store.hasSubscribers, registration) {
        case (true, nil):
            registration = remoteConfig.addOnConfigUpdateListener { [weak self, logger] update, error in
                if let error {
                    logger.error("Config update error: \(error.localizedDescription)")
                    return
                }
                guard update != nil else { return }
                // The listener is a synchronous callback with no async variant; hop onto the actor to
                // activate. Back-to-back updates queue serialized, idempotent activations.
                Task { await self?.activate() }
            }
            logger.debug("Real-time config listener started")
        case let (false, active?):
            active.remove()
            registration = nil
            logger.debug("Real-time config listener stopped")
        default:
            break
        }
    }
}

// MARK: - Private

extension RemoteConfigController {
    private func activate() async {
        do {
            _ = try await remoteConfig.activate()
            publishActiveValues()
            logger.info("Config updated and activated")
        } catch {
            logger.error("Config activation error: \(error.localizedDescription)")
        }
    }

    private func publishActiveValues() {
        let keys = remoteConfig.allKeys(from: .remote)
        let values = Dictionary(uniqueKeysWithValues: keys.map { key in
            (key, remoteConfig.configValue(forKey: key).dataValue)
        })
        store.publishRemoteValues(values)
    }
}
