//
//  FeatureFlagStore.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-05.
//

import Foundation
import os

// MARK: - FeatureFlagStore

/// Thread-safe holder of the current ``FeatureFlagSnapshot`` and fan-out point for config updates.
///
/// Reads are synchronous because ``FeatureFlagProviding`` exposes synchronous getters, so the state lives
/// in an `OSAllocatedUnfairLock` rather than an actor. Every call to ``updates()`` is an independent
/// subscriber; ``publishRemoteValues(_:)`` yields to all of them.
final class FeatureFlagStore: Sendable {
    // MARK: Properties

    private let state: OSAllocatedUnfairLock<State>
    private let onSubscribersChanged: @Sendable (_ hasSubscribers: Bool) -> Void

    // MARK: Initialization

    /// - Parameters:
    ///   - snapshot: The initial snapshot.
    ///   - onSubscribersChanged: Called with `true` when the first subscriber arrives and with `false` when
    ///     the last one terminates. Never called while the lock is held.
    init(snapshot: FeatureFlagSnapshot = FeatureFlagSnapshot(),
         onSubscribersChanged: @escaping @Sendable (_ hasSubscribers: Bool) -> Void = { _ in }) {
        state = OSAllocatedUnfairLock(initialState: State(snapshot: snapshot))
        self.onSubscribersChanged = onSubscribersChanged
    }

    /// Finishes every live stream so a consumer's `for await` loop ends instead of waiting forever.
    deinit {
        let subscribers = state.withLock { Array($0.subscribers.values) }
        for subscriber in subscribers {
            subscriber.finish()
        }
    }

    // MARK: Reading

    var snapshot: FeatureFlagSnapshot {
        state.withLock(\.snapshot)
    }

    var hasSubscribers: Bool {
        state.withLock { !$0.subscribers.isEmpty }
    }

    // MARK: Writing

    /// Replaces the registered defaults. Subscribers are not notified: defaults are not a config update.
    func replaceDefaults(_ defaults: [String: any Sendable]) {
        let encoded = FeatureFlagSnapshot().replacingDefaults(defaults).defaults
        state.withLock { $0.snapshot = FeatureFlagSnapshot(remoteValues: $0.snapshot.remoteValues, defaults: encoded) }
    }

    /// Swaps in new remote values, keeping the defaults, then notifies every live subscriber.
    func publishRemoteValues(_ values: [String: Data]) {
        let subscribers = state.withLock { state in
            state.snapshot = state.snapshot.replacingRemoteValues(values)
            return Array(state.subscribers.values)
        }
        for subscriber in subscribers {
            subscriber.yield()
        }
    }

    // MARK: Subscribing

    /// Returns a stream that yields once per ``publishRemoteValues(_:)`` until it is terminated.
    func updates() -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        let id = UUID()

        let isFirst = state.withLock { state in
            state.subscribers[id] = continuation
            return state.subscribers.count == 1
        }

        continuation.onTermination = { [weak self] _ in
            self?.removeSubscriber(id)
        }

        if isFirst {
            onSubscribersChanged(true)
        }
        return stream
    }
}

// MARK: - State

extension FeatureFlagStore {
    fileprivate struct State {
        var snapshot: FeatureFlagSnapshot
        var subscribers: [UUID: AsyncStream<Void>.Continuation] = [:]
    }

    private func removeSubscriber(_ id: UUID) {
        let wasLast = state.withLock { state in
            state.subscribers.removeValue(forKey: id) != nil && state.subscribers.isEmpty
        }
        if wasLast {
            onSubscribersChanged(false)
        }
    }
}
