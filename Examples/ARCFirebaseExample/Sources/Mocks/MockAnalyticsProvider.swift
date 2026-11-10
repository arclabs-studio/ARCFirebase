//
//  MockAnalyticsProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import Foundation
import os

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
final class MockAnalyticsProvider: AnalyticsProviding {
    private struct State {
        var loggedEvents: [LoggedEvent] = []
        var loggedScreenViews: [ScreenView] = []
        var userProperties: [String: String] = [:]
        var userID: String?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: Event Storage

    /// All logged events with their parameters.
    var loggedEvents: [LoggedEvent] {
        state.withLock { $0.loggedEvents }
    }

    /// All logged screen views.
    var loggedScreenViews: [ScreenView] {
        state.withLock { $0.loggedScreenViews }
    }

    /// Current user properties.
    var userProperties: [String: String] {
        state.withLock { $0.userProperties }
    }

    /// Current user ID.
    var userID: String? {
        state.withLock { $0.userID }
    }

    // MARK: Types

    /// Represents a logged analytics event.
    struct LoggedEvent {
        let name: String
        let parameters: [String: any Sendable]?
        let timestamp: Date

        init(name: String, parameters: [String: any Sendable]?) {
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

    func logEvent(_ name: String, parameters: [String: any Sendable]?) {
        let event = LoggedEvent(name: name, parameters: parameters)
        state.withLock { $0.loggedEvents.append(event) }

        // Print for debugging in previews
        #if DEBUG
        demoLogger.info("[MockAnalytics] Event: \(name), params: \(String(describing: parameters ?? [:]))")
        #endif
    }

    func logScreenView(_ screenName: String, screenClass: String?) {
        let screenView = ScreenView(screenName: screenName, screenClass: screenClass)
        state.withLock { $0.loggedScreenViews.append(screenView) }

        #if DEBUG
        demoLogger.info("[MockAnalytics] Screen: \(screenName)")
        #endif
    }

    func setUserProperty(_ name: String, value: String?) {
        if let value {
            state.withLock { $0.userProperties[name] = value }
        } else {
            state.withLock { _ = $0.userProperties.removeValue(forKey: name) }
        }
    }

    func setUserID(_ userID: String?) {
        state.withLock { $0.userID = userID }
    }

    // MARK: Testing Helpers

    /// Clears all logged events and screen views.
    func reset() {
        state.withLock { $0.loggedEvents.removeAll() }
        state.withLock { $0.loggedScreenViews.removeAll() }
        state.withLock { $0.userProperties.removeAll() }
        state.withLock { $0.userID = nil }
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
