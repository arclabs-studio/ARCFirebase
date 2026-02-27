import Testing
@testable import ARCFirebaseAnalytics

@Suite("FirebaseAnalyticsProvider Tests") struct FirebaseAnalyticsProviderTests {
    // MARK: - Mock Provider Tests

    @Test("logEvent records event with parameters") func logEvent_withParameters_recordsEvent() {
        // Given
        let mock = makeSUT()

        // When
        mock.logEvent("test_event", parameters: ["key": "value"])

        // Then
        #expect(mock.loggedEvents.count == 1)
        #expect(mock.loggedEvents[0].name == "test_event")
        #expect(mock.hasLoggedEvent("test_event"))
    }

    @Test("logEvent records event without parameters") func logEvent_withoutParameters_recordsNilParameters() {
        // Given
        let mock = makeSUT()

        // When
        mock.logEvent("simple_event")

        // Then
        #expect(mock.loggedEvents.count == 1)
        #expect(mock.loggedEvents[0].name == "simple_event")
        #expect(mock.loggedEvents[0].parameters == nil)
    }

    @Test("logScreenView records view with class name") func logScreenView_withClass_recordsView() {
        // Given
        let mock = makeSUT()

        // When
        mock.logScreenView("HomeScreen", screenClass: "HomeViewController")

        // Then
        #expect(mock.screenViews.count == 1)
        #expect(mock.screenViews[0].screenName == "HomeScreen")
        #expect(mock.screenViews[0].screenClass == "HomeViewController")
    }

    @Test("logScreenView records view without class name") func logScreenView_withoutClass_recordsNilClass() {
        // Given
        let mock = makeSUT()

        // When
        mock.logScreenView("SettingsScreen")

        // Then
        #expect(mock.screenViews.count == 1)
        #expect(mock.screenViews[0].screenName == "SettingsScreen")
        #expect(mock.screenViews[0].screenClass == nil)
    }

    @Test("setUserProperty stores multiple properties") func setUserProperty_withValues_storesProperties() {
        // Given
        let mock = makeSUT()

        // When
        mock.setUserProperty("subscription_type", value: "premium")
        mock.setUserProperty("user_level", value: "5")

        // Then
        #expect(mock.userProperties.count == 2)
        #expect(mock.userProperties["subscription_type"] == "premium")
        #expect(mock.userProperties["user_level"] == "5")
    }

    @Test("setUserProperty with nil value removes property") func setUserProperty_withNilValue_removesProperty() {
        // Given
        let mock = makeSUT()
        mock.setUserProperty("test_property", value: "test_value")
        #expect(mock.userProperties["test_property"] == "test_value")

        // When
        mock.setUserProperty("test_property", value: nil)

        // Then
        #expect(mock.userProperties["test_property"] == nil)
    }

    @Test("setUserID updates and clears user ID") func setUserID_withValueThenNil_updatesAndClearsID() {
        // Given
        let mock = makeSUT()

        // When
        mock.setUserID("user123")

        // Then
        #expect(mock.userID == "user123")

        // When
        mock.setUserID(nil)

        // Then
        #expect(mock.userID == nil)
    }

    @Test("logEvent called multiple times tracks all events") func logEvent_multipleTimes_tracksAll() {
        // Given
        let mock = makeSUT()

        // When
        mock.logEvent("event1")
        mock.logEvent("event2")
        mock.logEvent("event1")

        // Then
        #expect(mock.loggedEvents.count == 3)
        #expect(mock.eventCount(named: "event1") == 2)
        #expect(mock.eventCount(named: "event2") == 1)
    }

    @Test("lastEvent returns most recent occurrence of named event")
    func lastEvent_afterMultipleLogs_returnsLastOccurrence() {
        // Given
        let mock = makeSUT()
        mock.logEvent("first_event", parameters: ["order": "1"])
        mock.logEvent("second_event", parameters: ["order": "2"])
        mock.logEvent("first_event", parameters: ["order": "3"])

        // When
        let lastEvent = mock.lastEvent(named: "first_event")

        // Then
        #expect(lastEvent?.name == "first_event")
        if let parameters = lastEvent?.parameters {
            #expect((parameters["order"] as? String) == "3")
        } else {
            Issue.record("Expected parameters to exist")
        }
    }

    @Test("reset clears all recorded data") func reset_afterOperations_clearsAllState() {
        // Given
        let mock = makeSUT()
        mock.logEvent("test_event")
        mock.logScreenView("TestScreen")
        mock.setUserProperty("prop", value: "value")
        mock.setUserID("user123")

        // When
        mock.reset()

        // Then
        #expect(mock.loggedEvents.isEmpty)
        #expect(mock.screenViews.isEmpty)
        #expect(mock.userProperties.isEmpty)
        #expect(mock.userID == nil)
    }

    // MARK: - Predefined Constants Tests

    @Test("AnalyticsEvent constants match expected raw values") func analyticsEvent_constants_matchExpectedValues() {
        // Then
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

    @Test("AnalyticsParameter constants match expected raw values")
    func analyticsParameter_constants_matchExpectedValues() {
        // Then
        #expect(AnalyticsParameter.itemID == "item_id")
        #expect(AnalyticsParameter.itemName == "item_name")
        #expect(AnalyticsParameter.itemCategory == "item_category")
        #expect(AnalyticsParameter.searchQuery == "search_query")
        #expect(AnalyticsParameter.filterType == "filter_type")
        #expect(AnalyticsParameter.errorMessage == "error_message")
        #expect(AnalyticsParameter.screenName == "screen_name")
    }

    @Test("AnalyticsEvent names follow lowercase underscore convention")
    func analyticsEvent_names_followLowercaseUnderscore() {
        // Given
        let eventNames = [AnalyticsEvent.itemViewed,
                          AnalyticsEvent.searchPerformed,
                          AnalyticsEvent.onboardingCompleted]

        // Then
        for eventName in eventNames {
            #expect(!eventName.contains(" "))
            #expect(eventName == eventName.lowercased())
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> MockAnalyticsProvider {
        MockAnalyticsProvider()
    }
}
