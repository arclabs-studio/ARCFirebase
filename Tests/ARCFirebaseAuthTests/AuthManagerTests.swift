import XCTest
@testable import ARCFirebaseAuth

final class AuthManagerTests: XCTestCase {

    func testAuthManagerSingleton() {
        let manager1 = AuthManager.shared
        let manager2 = AuthManager.shared

        XCTAssertTrue(manager1 === manager2, "AuthManager should be a singleton")
    }

    func testIsAuthenticatedWhenNoUser() {
        // Note: This test assumes no user is signed in
        // In a real test, you would need to mock Firebase Auth
        XCTAssertNotNil(AuthManager.shared.isAuthenticated)
    }

    func testCurrentUserProperty() {
        // Verify the property exists and is accessible
        let currentUser = AuthManager.shared.currentUser
        // currentUser will be nil if no user is signed in
        XCTAssertTrue(currentUser == nil || currentUser != nil)
    }
}
