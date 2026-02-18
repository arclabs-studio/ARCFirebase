//
//  MockCrashlyticsProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseCrashlytics
import Foundation

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
final class MockCrashlyticsProvider: CrashlyticsProviding, @unchecked Sendable {
    // MARK: Recorded Data

    /// All recorded errors.
    private(set) var recordedErrors: [Error] = []

    /// All recorded non-fatal errors.
    private(set) var nonFatalErrors: [Error] = []

    /// All logged messages.
    private(set) var loggedMessages: [String] = []

    /// Current user ID.
    private(set) var currentUserID: String?

    /// Custom key-value pairs.
    private(set) var customValues: [String: any Sendable] = [:]

    // MARK: Initialization

    init() {}

    // MARK: CrashlyticsProviding Implementation

    func record(error: Error) {
        recordedErrors.append(error)

        #if DEBUG
        print("[MockCrashlytics] Recorded error: \(error.localizedDescription)")
        #endif
    }

    func recordNonFatal(error: Error) {
        nonFatalErrors.append(error)

        #if DEBUG
        print("[MockCrashlytics] Recorded non-fatal: \(error.localizedDescription)")
        #endif
    }

    func log(_ message: String) {
        loggedMessages.append(message)

        #if DEBUG
        print("[MockCrashlytics] Log: \(message)")
        #endif
    }

    func setUserID(_ userID: String) {
        currentUserID = userID
    }

    func clearUserID() {
        currentUserID = nil
    }

    func setCustomValue(_ value: any Sendable, forKey key: String) {
        customValues[key] = value
    }

    // MARK: Testing Helpers

    /// Clears all recorded data.
    func reset() {
        recordedErrors.removeAll()
        nonFatalErrors.removeAll()
        loggedMessages.removeAll()
        currentUserID = nil
        customValues.removeAll()
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
