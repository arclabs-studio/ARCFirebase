//
//  SubscriberChangeRecorder.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-05.
//

import os

/// Records, in call order, every Boolean a `FeatureFlagStore`'s `onSubscribersChanged` callback receives.
///
/// `onSubscribersChanged` is `@Sendable` and may be invoked from any isolation context, so the recorder
/// keeps its history behind an `OSAllocatedUnfairLock` instead of a plain, non-Sendable array.
final class SubscriberChangeRecorder: Sendable {
    private let state = OSAllocatedUnfairLock<[Bool]>(initialState: [])

    func record(_ hasSubscribers: Bool) {
        state.withLock { $0.append(hasSubscribers) }
    }

    var values: [Bool] {
        state.withLock { $0 }
    }
}
