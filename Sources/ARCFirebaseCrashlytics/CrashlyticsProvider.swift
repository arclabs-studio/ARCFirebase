//
//  CrashlyticsProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation

/// Protocol defining crash reporting capabilities.
///
/// Use this protocol for dependency injection to make your code testable
/// and decoupled from Firebase Crashlytics.
///
/// ## Usage in Production
///
/// ```swift
/// @MainActor
/// class MyViewModel: ObservableObject {
///     private let crashlytics: CrashlyticsProviding
///
///     init(crashlytics: CrashlyticsProviding) {
///         self.crashlytics = crashlytics
///     }
///
///     func handleError(_ error: Error) {
///         crashlytics.record(error: error)
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// final class MockCrashlyticsProvider: CrashlyticsProviding {
///     var recordedErrors: [Error] = []
///     var loggedMessages: [String] = []
///
///     func record(error: Error) {
///         recordedErrors.append(error)
///     }
///
///     func log(_ message: String) {
///         loggedMessages.append(message)
///     }
///
///     // ... other methods
/// }
/// ```
///
/// ## Topics
///
/// ### Error Recording
/// - ``record(error:)``
/// - ``recordNonFatal(error:)``
///
/// ### Custom Logging
/// - ``log(_:)``
///
/// ### User Context
/// - ``setUserID(_:)``
/// - ``clearUserID()``
/// - ``setCustomValue(_:forKey:)``
///
/// ### Implementations
/// - ``FirebaseCrashlyticsProvider``
public protocol CrashlyticsProviding: Sendable {
    /// Records an error with the crash reporting service.
    ///
    /// Use this to record errors that you catch and handle in your code.
    ///
    /// - Parameter error: The error to record.
    func record(error: Error)

    /// Records a non-fatal error.
    ///
    /// Non-fatal errors don't crash the app but are important to track.
    ///
    /// - Parameter error: The non-fatal error to record.
    func recordNonFatal(error: Error)

    /// Logs a custom message to the crash reporting service.
    ///
    /// Custom logs appear in crash reports to help understand what
    /// the user was doing before a crash.
    ///
    /// - Parameter message: The message to log.
    func log(_ message: String)

    /// Sets the user ID for crash reports.
    ///
    /// This helps identify which users are experiencing crashes.
    ///
    /// - Parameter userID: The user's unique identifier.
    ///
    /// - Important: Do NOT use email addresses or other PII as the user ID.
    func setUserID(_ userID: String)

    /// Clears the user ID from crash reports.
    ///
    /// Call this when the user signs out.
    func clearUserID()

    /// Sets a custom key-value pair for crash reports.
    ///
    /// Use this to add context to crash reports (e.g., user preferences, app state).
    ///
    /// - Parameters:
    ///   - value: The value to set (String, Bool, Int, Float, or Double).
    ///   - key: The key name (max 64 keys per session).
    func setCustomValue(_ value: any Sendable, forKey key: String)
}
