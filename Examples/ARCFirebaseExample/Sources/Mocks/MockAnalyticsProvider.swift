//
//  MockAnalyticsProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import Foundation

// MARK: - MockAnalyticsProvider

/// A mock implementation of `AnalyticsProviding` for SwiftUI previews and testing.
///
/// This provider captures all analytics events without sending them to Firebase,
/// making it perfect for:
/// - SwiftUI previews
/// - Unit testing (verify events are logged)
/// - Development without Firebase configuration
///
/// ## Example Usage
///
/// ```swift
/// // Create mock and track events
/// let mockAnalytics = MockAnalyticsProvider()
///
/// // Use in your code
/// mockAnalytics.logEvent("button_tapped", parameters: ["screen": "home"])
///
/// // Verify in tests
/// #expect(mockAnalytics.loggedEvents.count == 1)
/// #expect(mockAnalytics.loggedEvents.first?.name == "button_tapped")
/// ```
final class MockAnalyticsProvider: AnalyticsProviding, @unchecked Sendable {
    // MARK: Event Storage

    /// All logged events with their parameters.
    private(set) var loggedEvents: [LoggedEvent] = []

    /// All logged screen views.
    private(set) var loggedScreenViews: [ScreenView] = []

    /// Current user properties.
    private(set) var userProperties: [String: String] = [:]

    /// Current user ID.
    private(set) var userID: String?

    // MARK: Types

    /// Represents a logged analytics event.
    struct LoggedEvent {
        let name: String
        let parameters: [String: Any]?
        let timestamp: Date

        init(name: String, parameters: [String: Any]?) {
            self.name = name
            self.parameters = parameters
            timestamp = Date()
        }
    }

    /// Represents a logged screen view.
    struct ScreenView {
        let screenName: String
        let screenClass: String?
        let timestamp: Date

        init(screenName: String, screenClass: String?) {
            self.screenName = screenName
            self.screenClass = screenClass
            timestamp = Date()
        }
    }

    // MARK: Initialization

    init() {}

    // MARK: AnalyticsProviding Implementation

    func logEvent(_ name: String, parameters: [String: Any]?) {
        let event = LoggedEvent(name: name, parameters: parameters)
        loggedEvents.append(event)

        // Print for debugging in previews
        #if DEBUG
        print("[MockAnalytics] Event: \(name), params: \(parameters ?? [:])")
        #endif
    }

    func logScreenView(_ screenName: String, screenClass: String?) {
        let screenView = ScreenView(screenName: screenName, screenClass: screenClass)
        loggedScreenViews.append(screenView)

        #if DEBUG
        print("[MockAnalytics] Screen: \(screenName)")
        #endif
    }

    func setUserProperty(_ name: String, value: String?) {
        if let value {
            userProperties[name] = value
        } else {
            userProperties.removeValue(forKey: name)
        }
    }

    func setUserID(_ userID: String?) {
        self.userID = userID
    }

    // MARK: Testing Helpers

    /// Clears all logged events and screen views.
    func reset() {
        loggedEvents.removeAll()
        loggedScreenViews.removeAll()
        userProperties.removeAll()
        userID = nil
    }

    /// Returns true if an event with the given name was logged.
    func hasEvent(named name: String) -> Bool {
        loggedEvents.contains { $0.name == name }
    }

    /// Returns the count of events with the given name.
    func eventCount(named name: String) -> Int {
        loggedEvents.count(where: { $0.name == name })
    }
}

// MARK: - Convenience Initializers

extension MockAnalyticsProvider {
    /// Creates a shared mock provider for previews.
    static let preview = MockAnalyticsProvider()
}
