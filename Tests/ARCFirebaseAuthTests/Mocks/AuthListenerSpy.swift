//
//  AuthListenerSpy.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-11-06.
//

import Foundation
@testable import ARCFirebaseAuth

/// Records the listeners an ``AuthStateListenerRegistry`` adds and removes.
@MainActor
final class AuthListenerSpy {
    private(set) var addedHandles: [NSObject] = []
    private(set) var removedHandles: [NSObject] = []
    private var callbacks: [@Sendable (User?) -> Void] = []

    func makeRegistry() -> AuthStateListenerRegistry {
        AuthStateListenerRegistry(addListener: { [self] onChange in
            let handle = NSObject()
            addedHandles.append(handle)
            callbacks.append(onChange)
            return handle
        }, removeListener: { [self] handle in
            if let handle = handle as? NSObject {
                removedHandles.append(handle)
            }
        })
    }

    /// Simulates an auth-state change delivered to every added listener.
    func emit(_ user: User?) {
        for callback in callbacks {
            callback(user)
        }
    }
}
