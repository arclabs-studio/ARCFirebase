import Foundation
@testable import ARCFirebaseAnalytics

/// Mock analytics provider for testing.
final class MockAnalyticsProvider: AnalyticsProviding, @unchecked Sendable {
    // MARK: - Mock State

    private(set) var loggedEvents: [(name: String, parameters: [String: any Sendable]?)] = []
    private(set) var screenViews: [(screenName: String, screenClass: String?)] = []
    private(set) var userProperties: [String: String] = [:]
    private(set) var userID: String?

    // MARK: - AnalyticsProviding Implementation

    func logEvent(_ name: String, parameters: [String: any Sendable]?) {
        loggedEvents.append((name, parameters))
    }

    func logScreenView(_ screenName: String, screenClass: String?) {
        screenViews.append((screenName, screenClass))
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

    // MARK: - Test Helpers

    func reset() {
        loggedEvents.removeAll()
        screenViews.removeAll()
        userProperties.removeAll()
        userID = nil
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
