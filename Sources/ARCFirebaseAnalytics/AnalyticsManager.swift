import Foundation
import FirebaseAnalytics
import ARCFirebaseCore
import ARCLogger

/// Manages analytics event tracking with Firebase Analytics.
///
/// `AnalyticsManager` provides a type-safe interface to Firebase Analytics,
/// making it easy to track user behavior and app performance.
///
/// ## Topics
///
/// ### Configuration
/// - ``configure()``
///
/// ### Event Tracking
/// - ``logEvent(_:parameters:)``
/// - ``setUserProperty(_:value:)``
/// - ``setUserID(_:)``
///
/// ### Screen Tracking
/// - ``logScreenView(_:screenClass:)``
///
/// ### Guide
/// - <doc:EventTrackingGuide>
public final class AnalyticsManager {

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = AnalyticsManager()

    // MARK: - Properties

    private let logger = ARCLogger(category: "Analytics")

    // MARK: - Initialization

    private init() {}

    // MARK: - Configuration

    /// Configures the analytics manager.
    ///
    /// Call this after Firebase is configured.
    ///
    /// ```swift
    /// FirebaseManager.configure()
    /// try AnalyticsManager.shared.configure()
    /// ```
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public func configure() throws {
        try FirebaseManager.shared.ensureConfigured()
        logger.info("AnalyticsManager configured successfully")
    }

    // MARK: - Event Tracking

    /// Logs a custom analytics event.
    ///
    /// Use this to track user actions and behaviors in your app.
    ///
    /// ```swift
    /// AnalyticsManager.shared.logEvent("restaurant_viewed", parameters: [
    ///     "restaurant_id": "abc123",
    ///     "category": "italian",
    ///     "rating": "4.5"
    /// ])
    /// ```
    ///
    /// - Parameters:
    ///   - name: The event name (max 40 characters, alphanumeric + underscore).
    ///   - parameters: Optional event parameters (max 25 per event).
    ///
    /// - Note: Event names are case-sensitive. Use lowercase with underscores.
    ///
    /// - Important: Avoid logging PII (personally identifiable information).
    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
        logger.debug("Logged event: \(name)")
    }

    /// Sets a user property.
    ///
    /// User properties are attributes you define to describe segments of your user base.
    ///
    /// ```swift
    /// AnalyticsManager.shared.setUserProperty("premium", value: "true")
    /// AnalyticsManager.shared.setUserProperty("preferred_cuisine", value: "italian")
    /// ```
    ///
    /// - Parameters:
    ///   - name: The property name (max 24 characters).
    ///   - value: The property value (max 36 characters). Pass `nil` to clear.
    ///
    /// - Note: You can have up to 25 user properties per app.
    public func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
        logger.debug("Set user property: \(name) = \(value ?? "nil")")
    }

    /// Sets the user ID.
    ///
    /// Use this to associate events with a specific user across sessions and devices.
    ///
    /// ```swift
    /// AnalyticsManager.shared.setUserID(user.id)
    /// ```
    ///
    /// - Parameter userID: The user's unique identifier. Pass `nil` to clear.
    ///
    /// - Important: Do NOT use email addresses or other PII as the user ID.
    public func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
        logger.debug("Set user ID: \(userID ?? "nil")")
    }

    // MARK: - Screen Tracking

    /// Logs a screen view event.
    ///
    /// Use this to track which screens users visit in your app.
    ///
    /// ```swift
    /// AnalyticsManager.shared.logScreenView(
    ///     "RestaurantDetail",
    ///     screenClass: "RestaurantDetailView"
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - screenName: The name of the screen.
    ///   - screenClass: The class name of the screen (usually the view/controller name).
    public func logScreenView(_ screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        logger.debug("Logged screen view: \(screenName)")
    }
}
