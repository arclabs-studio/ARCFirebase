//
//  MockCrashlyticsProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
import os
@testable import ARCFirebaseCrashlytics

/// Mock crashlytics provider for testing.
final class MockCrashlyticsProvider: CrashlyticsProviding {
    private struct State {
        var recordedErrors: [Error] = []
        var recordedNonFatalErrors: [Error] = []
        var loggedMessages: [String] = []
        var currentUserID: String?
        var customValues: [String: any Sendable] = [:]
        var recordErrorCallCount: Int = 0
        var recordNonFatalCallCount: Int = 0
        var logCallCount: Int = 0
        var setUserIDCallCount: Int = 0
        var clearUserIDCallCount: Int = 0
        var setCustomValueCallCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var recordedErrors: [Error] {
        state.withLock { $0.recordedErrors }
    }

    var recordedNonFatalErrors: [Error] {
        state.withLock { $0.recordedNonFatalErrors }
    }

    var loggedMessages: [String] {
        state.withLock { $0.loggedMessages }
    }

    var currentUserID: String? {
        state.withLock { $0.currentUserID }
    }

    var customValues: [String: any Sendable] {
        state.withLock { $0.customValues }
    }

    // MARK: - Call Counts

    var recordErrorCallCount: Int {
        state.withLock { $0.recordErrorCallCount }
    }

    var recordNonFatalCallCount: Int {
        state.withLock { $0.recordNonFatalCallCount }
    }

    var logCallCount: Int {
        state.withLock { $0.logCallCount }
    }

    var setUserIDCallCount: Int {
        state.withLock { $0.setUserIDCallCount }
    }

    var clearUserIDCallCount: Int {
        state.withLock { $0.clearUserIDCallCount }
    }

    var setCustomValueCallCount: Int {
        state.withLock { $0.setCustomValueCallCount }
    }

    // MARK: - CrashlyticsProviding Implementation

    func record(error: Error) {
        state.withLock { $0.recordErrorCallCount += 1 }
        state.withLock { $0.recordedErrors.append(error) }
    }

    func recordNonFatal(error: Error) {
        state.withLock { $0.recordNonFatalCallCount += 1 }
        state.withLock { $0.recordedNonFatalErrors.append(error) }
    }

    func log(_ message: String) {
        state.withLock { $0.logCallCount += 1 }
        state.withLock { $0.loggedMessages.append(message) }
    }

    func setUserID(_ userID: String) {
        state.withLock { $0.setUserIDCallCount += 1 }
        state.withLock { $0.currentUserID = userID }
    }

    func clearUserID() {
        state.withLock { $0.clearUserIDCallCount += 1 }
        state.withLock { $0.currentUserID = nil }
    }

    func setCustomValue(_ value: any Sendable, forKey key: String) {
        state.withLock { $0.setCustomValueCallCount += 1 }
        state.withLock { $0.customValues[key] = value }
    }

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.recordedErrors = [] }
        state.withLock { $0.recordedNonFatalErrors = [] }
        state.withLock { $0.loggedMessages = [] }
        state.withLock { $0.currentUserID = nil }
        state.withLock { $0.customValues = [:] }
        state.withLock { $0.recordErrorCallCount = 0 }
        state.withLock { $0.recordNonFatalCallCount = 0 }
        state.withLock { $0.logCallCount = 0 }
        state.withLock { $0.setUserIDCallCount = 0 }
        state.withLock { $0.clearUserIDCallCount = 0 }
        state.withLock { $0.setCustomValueCallCount = 0 }
    }
}
