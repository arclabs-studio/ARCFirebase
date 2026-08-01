//
//  MockCrashlyticsProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
@testable import ARCFirebaseCrashlytics

/// Mock crashlytics provider for testing.
final class MockCrashlyticsProvider: CrashlyticsProviding, @unchecked Sendable {
    // MARK: - Mock State

    private(set) var recordedErrors: [Error] = []
    private(set) var recordedNonFatalErrors: [Error] = []
    private(set) var loggedMessages: [String] = []
    private(set) var currentUserID: String?
    private(set) var customValues: [String: Any] = [:]

    // MARK: - Call Counts

    private(set) var recordErrorCallCount = 0
    private(set) var recordNonFatalCallCount = 0
    private(set) var logCallCount = 0
    private(set) var setUserIDCallCount = 0
    private(set) var clearUserIDCallCount = 0
    private(set) var setCustomValueCallCount = 0

    // MARK: - CrashlyticsProviding Implementation

    func record(error: Error) {
        recordErrorCallCount += 1
        recordedErrors.append(error)
    }

    func recordNonFatal(error: Error) {
        recordNonFatalCallCount += 1
        recordedNonFatalErrors.append(error)
    }

    func log(_ message: String) {
        logCallCount += 1
        loggedMessages.append(message)
    }

    func setUserID(_ userID: String) {
        setUserIDCallCount += 1
        currentUserID = userID
    }

    func clearUserID() {
        clearUserIDCallCount += 1
        currentUserID = nil
    }

    func setCustomValue(_ value: Any, forKey key: String) {
        setCustomValueCallCount += 1
        customValues[key] = value
    }

    // MARK: - Test Helpers

    func reset() {
        recordedErrors = []
        recordedNonFatalErrors = []
        loggedMessages = []
        currentUserID = nil
        customValues = [:]
        recordErrorCallCount = 0
        recordNonFatalCallCount = 0
        logCallCount = 0
        setUserIDCallCount = 0
        clearUserIDCallCount = 0
        setCustomValueCallCount = 0
    }
}
