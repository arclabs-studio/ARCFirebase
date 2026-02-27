//
//  FirebaseCrashlyticsProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseCrashlytics
import Foundation

/// Firebase implementation of ``CrashlyticsProviding``.
///
/// This is the production crash reporting provider that uses Firebase Crashlytics.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance
/// let crashlytics = try FirebaseCrashlyticsProvider()
///
/// // Or use the convenience default
/// let crashlytics = FirebaseCrashlyticsProvider.live
/// ```
///
/// ## SwiftUI Integration
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let crashlytics = FirebaseCrashlyticsProvider.live
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.crashlyticsProvider, crashlytics)
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
/// - ``live``
/// - ``create()``
///
/// ### CrashlyticsProviding Implementation
/// - ``record(error:)``
/// - ``recordNonFatal(error:)``
/// - ``log(_:)``
/// - ``setUserID(_:)``
/// - ``clearUserID()``
/// - ``setCustomValue(_:forKey:)``
public final class FirebaseCrashlyticsProvider: CrashlyticsProviding, @unchecked Sendable {
    // MARK: - Properties

    private let crashlytics: Crashlytics
    private let logger: ARCLogger

    // MARK: - Initialization

    /// Creates a Firebase crashlytics provider.
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init() throws {
        try FirebaseManager.ensureConfigured()
        crashlytics = Crashlytics.crashlytics()
        logger = ARCLogger(subsystem: "com.arclabs-studio.arcfirebase", category: "Crashlytics")
        logger.info("FirebaseCrashlyticsProvider initialized")
    }

    // MARK: - CrashlyticsProviding Implementation

    public func record(error: Error) {
        crashlytics.record(error: error)
        logger.debug("Recorded error: \(error.localizedDescription)")
    }

    public func recordNonFatal(error: Error) {
        crashlytics.record(error: error)
        logger.warning("Recorded non-fatal error: \(error.localizedDescription)")
    }

    public func log(_ message: String) {
        crashlytics.log(message)
        logger.debug("Logged to Crashlytics: \(message)")
    }

    public func setUserID(_ userID: String) {
        crashlytics.setUserID(userID)
        logger.debug("Set Crashlytics user ID: \(userID)")
    }

    public func clearUserID() {
        crashlytics.setUserID("")
        logger.debug("Cleared Crashlytics user ID")
    }

    public func setCustomValue(_ value: any Sendable, forKey key: String) {
        crashlytics.setCustomValue(value, forKey: key)
        logger.debug("Set custom value: \(key) = \(value)")
    }
}

// MARK: - Factory Methods

extension FirebaseCrashlyticsProvider {
    /// Creates a new instance with explicit error handling.
    ///
    /// Use this method when you want to handle initialization errors:
    ///
    /// ```swift
    /// do {
    ///     let crashlytics = try FirebaseCrashlyticsProvider.create()
    /// } catch {
    ///     // Handle configuration error
    /// }
    /// ```
    ///
    /// - Returns: A configured ``FirebaseCrashlyticsProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create() throws -> FirebaseCrashlyticsProvider {
        try FirebaseCrashlyticsProvider()
    }

    /// Default live instance for production use.
    ///
    /// - Important: This will crash if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first.
    public static var live: FirebaseCrashlyticsProvider {
        do {
            return try create()
        } catch {
            fatalError("""
            FirebaseCrashlyticsProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(error.localizedDescription)
            """)
        }
    }
}
