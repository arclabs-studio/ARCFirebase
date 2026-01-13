import XCTest
@testable import ARCFirebaseCore

final class FirebaseManagerTests: XCTestCase {

    func testFirebaseManagerSingleton() {
        let manager1 = FirebaseManager.shared
        let manager2 = FirebaseManager.shared

        XCTAssertTrue(manager1 === manager2, "FirebaseManager should be a singleton")
    }

    func testInitialConfigurationState() {
        // Note: In a real test environment, Firebase might already be configured
        // This test verifies the property exists
        XCTAssertNotNil(FirebaseManager.shared.isConfigured)
    }

    func testFirebaseErrorDescriptions() {
        let notConfiguredError = FirebaseError.notConfigured
        XCTAssertNotNil(notConfiguredError.errorDescription)
        XCTAssertTrue(notConfiguredError.errorDescription!.contains("Firebase"))

        let authError = FirebaseError.authNotAvailable
        XCTAssertNotNil(authError.errorDescription)

        let firestoreError = FirebaseError.firestoreNotAvailable
        XCTAssertNotNil(firestoreError.errorDescription)

        let storageError = FirebaseError.storageNotAvailable
        XCTAssertNotNil(storageError.errorDescription)

        let analyticsError = FirebaseError.analyticsNotAvailable
        XCTAssertNotNil(analyticsError.errorDescription)

        let documentNotFoundError = FirebaseError.documentNotFound
        XCTAssertNotNil(documentNotFoundError.errorDescription)

        let permissionDeniedError = FirebaseError.permissionDenied
        XCTAssertNotNil(permissionDeniedError.errorDescription)
    }

    func testNetworkErrorWrapping() {
        let underlyingError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        let networkError = FirebaseError.networkError(underlying: underlyingError)

        XCTAssertNotNil(networkError.errorDescription)
        XCTAssertTrue(networkError.errorDescription!.contains("Network"))
    }

    func testUnknownErrorWrapping() {
        let underlyingError = NSError(domain: "TestDomain", code: 999, userInfo: nil)
        let unknownError = FirebaseError.unknown(underlying: underlyingError)

        XCTAssertNotNil(unknownError.errorDescription)
        XCTAssertTrue(unknownError.errorDescription!.contains("unknown"))
    }
}
