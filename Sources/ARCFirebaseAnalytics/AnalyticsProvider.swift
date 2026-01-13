import Foundation

/// Protocol defining analytics tracking capabilities.
///
/// Use this protocol for dependency injection to make your code testable.
///
/// ## Usage in Production
///
/// ```swift
/// class MyViewModel {
///     private let analytics: AnalyticsProviding
///
///     init(analytics: AnalyticsProviding) {
///         self.analytics = analytics
///     }
///
///     func trackAction() {
///         analytics.logEvent("user_action", parameters: ["key": "value"])
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// final class MockAnalyticsProvider: AnalyticsProviding {
///     var loggedEvents: [(String, [String: Any]?)] = []
///
///     func logEvent(_ name: String, parameters: [String: Any]?) {
///         loggedEvents.append((name, parameters))
///     }
///
///     func logScreenView(_ screenName: String, screenClass: String?) {
///         loggedEvents.append(("screen_view", ["screen": screenName]))
///     }
///
///     func setUserProperty(_ name: String, value: String?) {}
///     func setUserID(_ userID: String?) {}
/// }
///
/// func testViewModel() {
///     let mock = MockAnalyticsProvider()
///     let viewModel = MyViewModel(analytics: mock)
///
///     viewModel.trackAction()
///
///     #expect(mock.loggedEvents.count == 1)
///     #expect(mock.loggedEvents[0].0 == "user_action")
/// }
/// ```
///
/// ## Topics
///
/// ### Event Tracking
/// - ``logEvent(_:parameters:)``
/// - ``logScreenView(_:screenClass:)``
///
/// ### User Properties
/// - ``setUserProperty(_:value:)``
/// - ``setUserID(_:)``
///
/// ### Implementations
/// - ``FirebaseAnalyticsProvider``
public protocol AnalyticsProviding: Sendable {

    /// Logs a custom analytics event.
    ///
    /// - Parameters:
    ///   - name: The event name (max 40 characters).
    ///   - parameters: Optional event parameters (max 25 per event).
    func logEvent(_ name: String, parameters: [String: Any]?)

    /// Logs a screen view event.
    ///
    /// - Parameters:
    ///   - screenName: The name of the screen.
    ///   - screenClass: The class name of the screen.
    func logScreenView(_ screenName: String, screenClass: String?)

    /// Sets a user property.
    ///
    /// - Parameters:
    ///   - name: The property name (max 24 characters).
    ///   - value: The property value (max 36 characters). Pass `nil` to clear.
    func setUserProperty(_ name: String, value: String?)

    /// Sets the user ID.
    ///
    /// - Parameter userID: The user's unique identifier. Pass `nil` to clear.
    func setUserID(_ userID: String?)
}

// MARK: - Default Parameters

extension AnalyticsProviding {

    /// Logs an event without parameters.
    public func logEvent(_ name: String) {
        logEvent(name, parameters: nil)
    }

    /// Logs a screen view with default screen class.
    public func logScreenView(_ screenName: String) {
        logScreenView(screenName, screenClass: nil)
    }
}
