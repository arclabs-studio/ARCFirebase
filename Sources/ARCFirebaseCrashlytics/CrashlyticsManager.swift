import Foundation
import FirebaseCrashlytics
import ARCFirebaseCore
import ARCLogger

/// Manages crash reporting with Firebase Crashlytics.
///
/// `CrashlyticsManager` provides a simple interface to Firebase Crashlytics
/// for tracking crashes, non-fatal errors, and custom logs.
///
/// ## Topics
///
/// ### Configuration
/// - ``configure()``
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
/// - ``setCustomValue(_:forKey:)``
///
/// ### Guide
/// - <doc:CrashReportingGuide>
public final class CrashlyticsManager: @unchecked Sendable {

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = CrashlyticsManager()

    // MARK: - Properties

    private let logger = ARCLogger(category: "Crashlytics")
    private let crashlytics = Crashlytics.crashlytics()

    // MARK: - Initialization

    private init() {}

    // MARK: - Configuration

    /// Configures the crashlytics manager.
    ///
    /// Call this after Firebase is configured.
    ///
    /// ```swift
    /// FirebaseManager.configure()
    /// try CrashlyticsManager.shared.configure()
    /// ```
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public func configure() throws {
        try FirebaseManager.ensureConfigured()
        logger.info("CrashlyticsManager configured successfully")
    }

    // MARK: - Error Recording

    /// Records an error with Crashlytics.
    ///
    /// Use this to record errors that you catch and handle in your code.
    ///
    /// ```swift
    /// do {
    ///     try someOperation()
    /// } catch {
    ///     CrashlyticsManager.shared.record(error: error)
    /// }
    /// ```
    ///
    /// - Parameter error: The error to record.
    public func record(error: Error) {
        crashlytics.record(error: error)
        logger.debug("Recorded error: \(error.localizedDescription)")
    }

    /// Records a non-fatal error.
    ///
    /// Non-fatal errors don't crash the app but are important to track.
    ///
    /// ```swift
    /// if let error = validationError {
    ///     CrashlyticsManager.shared.recordNonFatal(error: error)
    /// }
    /// ```
    ///
    /// - Parameter error: The non-fatal error to record.
    public func recordNonFatal(error: Error) {
        crashlytics.record(error: error)
        logger.warning("Recorded non-fatal error: \(error.localizedDescription)")
    }

    // MARK: - Custom Logging

    /// Logs a custom message to Crashlytics.
    ///
    /// Custom logs appear in crash reports to help you understand what
    /// the user was doing before a crash.
    ///
    /// ```swift
    /// CrashlyticsManager.shared.log("User viewed restaurant: \(restaurantID)")
    /// ```
    ///
    /// - Parameter message: The message to log (max 64KB per session).
    public func log(_ message: String) {
        crashlytics.log(message)
        logger.debug("Logged to Crashlytics: \(message)")
    }

    // MARK: - User Context

    /// Sets the user ID for crash reports.
    ///
    /// This helps you identify which users are experiencing crashes.
    ///
    /// ```swift
    /// CrashlyticsManager.shared.setUserID(user.id)
    /// ```
    ///
    /// - Parameter userID: The user's unique identifier.
    ///
    /// - Important: Do NOT use email addresses or other PII as the user ID.
    public func setUserID(_ userID: String) {
        crashlytics.setUserID(userID)
        logger.debug("Set Crashlytics user ID: \(userID)")
    }

    /// Sets a custom key-value pair for crash reports.
    ///
    /// Use this to add context to crash reports (e.g., user preferences, app state).
    ///
    /// ```swift
    /// CrashlyticsManager.shared.setCustomValue("true", forKey: "is_premium_user")
    /// CrashlyticsManager.shared.setCustomValue("dark", forKey: "theme")
    /// ```
    ///
    /// - Parameters:
    ///   - value: The value to set (String, Bool, Int, Float, or Double).
    ///   - key: The key name (max 64 keys per session).
    public func setCustomValue<T>(_ value: T, forKey key: String) {
        crashlytics.setCustomValue(value, forKey: key)
        logger.debug("Set custom value: \(key) = \(value)")
    }
}
