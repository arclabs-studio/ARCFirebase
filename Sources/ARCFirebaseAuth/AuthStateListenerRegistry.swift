//
//  AuthStateListenerRegistry.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-11-06.
//

import Foundation

/// Owns the auth-state listener handles on the main actor.
///
/// Registration and removal both hop to the main actor. If a stream terminates before its
/// registration ran, the identifier is remembered so the late registration is skipped.
///
/// The listener source is injected so the registration bookkeeping can be tested without a
/// configured Firebase app; production code uses ``shared``, which is backed by `Auth.auth()`.
@MainActor
final class AuthStateListenerRegistry {
    /// Adds a listener that forwards every auth-state change, returning its removal handle.
    typealias AddListener = @MainActor (_ onChange: @escaping @Sendable (User?) -> Void) -> any NSObjectProtocol

    /// Removes a listener previously returned by ``AddListener``.
    typealias RemoveListener = @MainActor (_ handle: any NSObjectProtocol) -> Void

    private let addListener: AddListener
    private let removeListener: RemoveListener
    private var handles: [UUID: any NSObjectProtocol] = [:]
    private var terminatedBeforeRegistration: Set<UUID> = []

    init(addListener: @escaping AddListener, removeListener: @escaping RemoveListener) {
        self.addListener = addListener
        self.removeListener = removeListener
    }

    /// Starts forwarding auth-state changes to `continuation`, unless `id` already terminated.
    func register(_ id: UUID, continuation: AsyncStream<User?>.Continuation) {
        guard terminatedBeforeRegistration.remove(id) == nil else { return }
        handles[id] = addListener { user in
            continuation.yield(user)
        }
    }

    /// Removes the listener for `id`, or remembers `id` if it has not registered yet.
    func unregister(_ id: UUID) {
        if let handle = handles.removeValue(forKey: id) {
            removeListener(handle)
        } else {
            terminatedBeforeRegistration.insert(id)
        }
    }
}
