import XCTest
@testable import ARCFirebaseAnalytics

final class AnalyticsManagerTests: XCTestCase {

    func testAnalyticsManagerSingleton() {
        let manager1 = AnalyticsManager.shared
        let manager2 = AnalyticsManager.shared

        XCTAssertTrue(manager1 === manager2, "AnalyticsManager should be a singleton")
    }

    func testPredefinedEventNames() {
        XCTAssertEqual(AnalyticsEvent.itemViewed, "item_viewed")
        XCTAssertEqual(AnalyticsEvent.itemFavorited, "item_favorited")
        XCTAssertEqual(AnalyticsEvent.itemUnfavorited, "item_unfavorited")
        XCTAssertEqual(AnalyticsEvent.itemShared, "item_shared")
        XCTAssertEqual(AnalyticsEvent.searchPerformed, "search_performed")
        XCTAssertEqual(AnalyticsEvent.filterApplied, "filter_applied")
        XCTAssertEqual(AnalyticsEvent.onboardingCompleted, "onboarding_completed")
        XCTAssertEqual(AnalyticsEvent.appOpened, "app_opened")
        XCTAssertEqual(AnalyticsEvent.errorOccurred, "error_occurred")
    }

    func testPredefinedParameterNames() {
        XCTAssertEqual(AnalyticsParameter.itemID, "item_id")
        XCTAssertEqual(AnalyticsParameter.itemName, "item_name")
        XCTAssertEqual(AnalyticsParameter.itemCategory, "item_category")
        XCTAssertEqual(AnalyticsParameter.searchQuery, "search_query")
        XCTAssertEqual(AnalyticsParameter.filterType, "filter_type")
        XCTAssertEqual(AnalyticsParameter.errorMessage, "error_message")
        XCTAssertEqual(AnalyticsParameter.screenName, "screen_name")
    }

    func testEventNamingConvention() {
        // Verify event names follow lowercase_with_underscores convention
        let eventNames = [
            AnalyticsEvent.itemViewed,
            AnalyticsEvent.searchPerformed,
            AnalyticsEvent.onboardingCompleted
        ]

        for eventName in eventNames {
            XCTAssertFalse(eventName.contains(" "), "Event name should not contain spaces")
            XCTAssertEqual(eventName, eventName.lowercased(), "Event name should be lowercase")
        }
    }
}
