import XCTest
@testable import ARCFirebaseCrashlytics

final class CrashlyticsManagerTests: XCTestCase {

    func testCrashlyticsManagerSingleton() {
        let manager1 = CrashlyticsManager.shared
        let manager2 = CrashlyticsManager.shared

        XCTAssertTrue(manager1 === manager2, "CrashlyticsManager should be a singleton")
    }

    func testManagerExists() {
        // Verify the manager can be accessed
        XCTAssertNotNil(CrashlyticsManager.shared)
    }
}
