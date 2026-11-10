//
//  MockCrashlyticsProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseCrashlytics
import Foundation
import os

// MARK: - MockCrashlyticsProvider

/// A mock implementation of `CrashlyticsProviding` for SwiftUI previews and testing.
///
/// This provider captures all crash reports and logs without sending them to Firebase,
/// making it perfect for:
/// - SwiftUI previews
/// - Unit testing (verify errors are recorded)
/// - Development without Firebase configuration
///
/// ## Example Usage
///
/// ```swift
/// let mockCrashlytics = MockCrashlyticsProvider()
///
/// // Record an error
/// mockCrashlytics.record(error: MyError.somethingWentWrong)
///
/// // Verify in tests
/// #expect(mockCrashlytics.recordedErrors.count == 1)
/// ```
final class MockCrashlyticsProvider: CrashlyticsProviding {
    private struct State {
        var recordedErrors: [Error] = []
        var nonFatalErrors: [Error] = []
        var loggedMessages: [String] = []
        var currentUserID: String?
        var customValues: [String: any Sendable] = [:]
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: Recorded Data

    /// All recorded errors.
    var recordedErrors: [Error] {
        state.withLock { $0.recordedErrors }
    }

    /// All recorded non-fatal errors.
    var nonFatalErrors: [Error] {
        state.withLock { $0.nonFatalErrors }
    }

    /// All logged messages.
    var loggedMessages: [String] {
        state.withLock { $0.loggedMessages }
    }

    /// Current user ID.
    var currentUserID: String? {
        state.withLock { $0.currentUserID }
    }

    /// Custom key-value pairs.
    var customValues: [String: any Sendable] {
        state.withLock { $0.customValues }
    }

    // MARK: Initialization

    init() {}

    // MARK: CrashlyticsProviding Implementation

    func record(error: Error) {
        state.withLock { $0.recordedErrors.append(error) }

        #if DEBUG
        demoLogger.error("[MockCrashlytics] Recorded error: \(error.localizedDescription)")
        #endif
    }

    func recordNonFatal(error: Error) {
        state.withLock { $0.nonFatalErrors.append(error) }

        #if DEBUG
        demoLogger.error("[MockCrashlytics] Recorded non-fatal: \(error.localizedDescription)")
        #endif
    }

    func log(_ message: String) {
        state.withLock { $0.loggedMessages.append(message) }

        #if DEBUG
        demoLogger.info("[MockCrashlytics] Log: \(message)")
        #endif
    }

    func setUserID(_ userID: String) {
        state.withLock { $0.currentUserID = userID }
    }

    func clearUserID() {
        state.withLock { $0.currentUserID = nil }
    }

    func setCustomValue(_ value: any Sendable, forKey key: String) {
        state.withLock { $0.customValues[key] = value }
    }

    // MARK: Testing Helpers

    /// Clears all recorded data.
    func reset() {
        state.withLock { $0.recordedErrors.removeAll() }
        state.withLock { $0.nonFatalErrors.removeAll() }
        state.withLock { $0.loggedMessages.removeAll() }
        state.withLock { $0.currentUserID = nil }
        state.withLock { $0.customValues.removeAll() }
    }

    /// Returns true if any error was recorded.
    var hasRecordedErrors: Bool {
        !recordedErrors.isEmpty || !nonFatalErrors.isEmpty
    }

    /// Total count of all recorded errors (fatal + non-fatal).
    var totalErrorCount: Int {
        recordedErrors.count + nonFatalErrors.count
    }
}

// MARK: - Convenience Initializers

extension MockCrashlyticsProvider {
    /// Creates a shared mock provider for previews.
    static let preview = MockCrashlyticsProvider()
}
