import Foundation
import os
@testable import ARCFirebaseAnalytics

/// Mock analytics provider for testing.
final class MockAnalyticsProvider: AnalyticsProviding {
    private struct State {
        var loggedEvents: [(name: String, parameters: [String: any Sendable]?)] = []
        var screenViews: [(screenName: String, screenClass: String?)] = []
        var userProperties: [String: String] = [:]
        var userID: String?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var loggedEvents: [(name: String, parameters: [String: any Sendable]?)] {
        state.withLock { $0.loggedEvents }
    }

    var screenViews: [(screenName: String, screenClass: String?)] {
        state.withLock { $0.screenViews }
    }

    var userProperties: [String: String] {
        state.withLock { $0.userProperties }
    }

    var userID: String? {
        state.withLock { $0.userID }
    }

    // MARK: - AnalyticsProviding Implementation

    func logEvent(_ name: String, parameters: [String: any Sendable]?) {
        state.withLock { $0.loggedEvents.append((name, parameters)) }
    }

    func logScreenView(_ screenName: String, screenClass: String?) {
        state.withLock { $0.screenViews.append((screenName, screenClass)) }
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

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.loggedEvents.removeAll() }
        state.withLock { $0.screenViews.removeAll() }
        state.withLock { $0.userProperties.removeAll() }
        state.withLock { $0.userID = nil }
    }

    func eventCount(named name: String) -> Int {
        loggedEvents.count(where: { $0.name == name })
    }

    func lastEvent(named name: String) -> (name: String, parameters: [String: any Sendable]?)? {
        loggedEvents.last { $0.name == name }
    }

    func hasLoggedEvent(_ name: String) -> Bool {
        loggedEvents.contains { $0.name == name }
    }
}
