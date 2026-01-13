import Foundation
import FirebaseAnalytics
import ARCFirebaseCore
import ARCLogger

/// Firebase implementation of ``AnalyticsProviding``.
///
/// This is the production analytics provider that uses Firebase Analytics.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance
/// let analytics = try FirebaseAnalyticsProvider()
///
/// // Or use the convenience default
/// let analytics = FirebaseAnalyticsProvider.live
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
/// - ``live``
public final class FirebaseAnalyticsProvider: AnalyticsProviding, @unchecked Sendable {

    // MARK: - Properties

    private let logger = ARCLogger(category: "FirebaseAnalytics")

    // MARK: - Initialization

    /// Creates a Firebase analytics provider.
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init() throws {
        try FirebaseManager.shared.ensureConfigured()
        logger.info("FirebaseAnalyticsProvider initialized")
    }

    // MARK: - AnalyticsProviding Implementation

    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        logger.debug("Logged event: \(name)")
    }

    public func logScreenView(_ screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        logger.debug("Logged screen view: \(screenName)")
    }

    public func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
        logger.debug("Set user property: \(name) = \(value ?? "nil")")
    }

    public func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
        logger.debug("Set user ID: \(userID ?? "nil")")
    }
}

// MARK: - Convenience

extension FirebaseAnalyticsProvider {

    /// Default live instance for production use.
    public static var live: FirebaseAnalyticsProvider {
        try! FirebaseAnalyticsProvider()
    }
}
