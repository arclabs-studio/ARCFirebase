import Testing
@testable import ARCFirebaseAnalytics

@Suite("AnalyticsManager Tests")
struct AnalyticsManagerTests {

    @Test("AnalyticsManager is a singleton")
    func analyticsManagerSingleton() {
        let manager1 = AnalyticsManager.shared
        let manager2 = AnalyticsManager.shared

        #expect(manager1 === manager2)
    }

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
