import Testing
@testable import ARCFirebaseAnalytics

@Suite("FirebaseAnalyticsProvider Tests")
struct FirebaseAnalyticsProviderTests {
    // MARK: - Mock Provider Tests

    @Test("Mock provider logs events")
    func mockLogsEvents() {
        let mock = MockAnalyticsProvider()

        mock.logEvent("test_event", parameters: ["key": "value"])

        #expect(mock.loggedEvents.count == 1)
        #expect(mock.loggedEvents[0].name == "test_event")
        #expect(mock.hasLoggedEvent("test_event"))
    }

    @Test("Mock provider logs events without parameters")
    func mockLogsEventsWithoutParameters() {
        let mock = MockAnalyticsProvider()

        mock.logEvent("simple_event")

        #expect(mock.loggedEvents.count == 1)
        #expect(mock.loggedEvents[0].name == "simple_event")
        #expect(mock.loggedEvents[0].parameters == nil)
    }

    @Test("Mock provider logs screen views")
    func mockLogsScreenViews() {
        let mock = MockAnalyticsProvider()

        mock.logScreenView("HomeScreen", screenClass: "HomeViewController")

        #expect(mock.screenViews.count == 1)
        #expect(mock.screenViews[0].screenName == "HomeScreen")
        #expect(mock.screenViews[0].screenClass == "HomeViewController")
    }

    @Test("Mock provider logs screen views without class")
    func mockLogsScreenViewsWithoutClass() {
        let mock = MockAnalyticsProvider()

        mock.logScreenView("SettingsScreen")

        #expect(mock.screenViews.count == 1)
        #expect(mock.screenViews[0].screenName == "SettingsScreen")
        #expect(mock.screenViews[0].screenClass == nil)
    }

    @Test("Mock provider sets user properties")
    func mockSetsUserProperties() {
        let mock = MockAnalyticsProvider()

        mock.setUserProperty("subscription_type", value: "premium")
        mock.setUserProperty("user_level", value: "5")

        #expect(mock.userProperties.count == 2)
        #expect(mock.userProperties["subscription_type"] == "premium")
        #expect(mock.userProperties["user_level"] == "5")
    }

    @Test("Mock provider clears user properties")
    func mockClearsUserProperties() {
        let mock = MockAnalyticsProvider()

        mock.setUserProperty("test_property", value: "test_value")
        #expect(mock.userProperties["test_property"] == "test_value")

        mock.setUserProperty("test_property", value: nil)
        #expect(mock.userProperties["test_property"] == nil)
    }

    @Test("Mock provider sets user ID")
    func mockSetsUserID() {
        let mock = MockAnalyticsProvider()

        mock.setUserID("user123")
        #expect(mock.userID == "user123")

        mock.setUserID(nil)
        #expect(mock.userID == nil)
    }

    @Test("Mock provider tracks multiple events")
    func mockTracksMultipleEvents() {
        let mock = MockAnalyticsProvider()

        mock.logEvent("event1")
        mock.logEvent("event2")
        mock.logEvent("event1")

        #expect(mock.loggedEvents.count == 3)
        #expect(mock.eventCount(named: "event1") == 2)
        #expect(mock.eventCount(named: "event2") == 1)
    }

    @Test("Mock provider retrieves last event")
    func mockRetrievesLastEvent() {
        let mock = MockAnalyticsProvider()

        mock.logEvent("first_event", parameters: ["order": "1"])
        mock.logEvent("second_event", parameters: ["order": "2"])
        mock.logEvent("first_event", parameters: ["order": "3"])

        let lastEvent = mock.lastEvent(named: "first_event")
        #expect(lastEvent?.name == "first_event")

        if let parameters = lastEvent?.parameters {
            #expect((parameters["order"] as? String) == "3")
        } else {
            Issue.record("Expected parameters to exist")
        }
    }

    @Test("Mock reset clears all data")
    func mockResetClearsAllData() {
        let mock = MockAnalyticsProvider()

        mock.logEvent("test_event")
        mock.logScreenView("TestScreen")
        mock.setUserProperty("prop", value: "value")
        mock.setUserID("user123")

        mock.reset()

        #expect(mock.loggedEvents.isEmpty)
        #expect(mock.screenViews.isEmpty)
        #expect(mock.userProperties.isEmpty)
        #expect(mock.userID == nil)
    }

    // MARK: - Predefined Constants Tests

    @Test("Predefined event names match expected values")
    func predefinedEventNames() {
        #expect(AnalyticsEvent.itemViewed == "item_viewed")
        #expect(AnalyticsEvent.itemFavorited == "item_favorited")
        #expect(AnalyticsEvent.itemUnfavorited == "item_unfavorited")
        #expect(AnalyticsEvent.itemShared == "item_shared")
        #expect(AnalyticsEvent.searchPerformed == "search_performed")
        #expect(AnalyticsEvent.filterApplied == "filter_applied")
        #expect(AnalyticsEvent.onboardingCompleted == "onboarding_completed")
        #expect(AnalyticsEvent.appOpened == "app_opened")
        #expect(AnalyticsEvent.errorOccurred == "error_occurred")
    }

    @Test("Predefined parameter names match expected values")
    func predefinedParameterNames() {
        #expect(AnalyticsParameter.itemID == "item_id")
        #expect(AnalyticsParameter.itemName == "item_name")
        #expect(AnalyticsParameter.itemCategory == "item_category")
        #expect(AnalyticsParameter.searchQuery == "search_query")
        #expect(AnalyticsParameter.filterType == "filter_type")
        #expect(AnalyticsParameter.errorMessage == "error_message")
        #expect(AnalyticsParameter.screenName == "screen_name")
    }

    @Test("Event names follow naming convention")
    func eventNamingConvention() {
        // Verify event names follow lowercase_with_underscores convention
        let eventNames = [
            AnalyticsEvent.itemViewed,
            AnalyticsEvent.searchPerformed,
            AnalyticsEvent.onboardingCompleted
        ]

        for eventName in eventNames {
            #expect(!eventName.contains(" "))
            #expect(eventName == eventName.lowercased())
        }
    }
}
