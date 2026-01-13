import XCTest
@testable import ARCFirebasePersistence

final class FirestoreRepositoryTests: XCTestCase {

    struct TestEntity: Identifiable, Codable {
        let id: String
        let name: String
    }

    func testFirestoreDocumentProtocol() {
        // Verify FirestoreDocument protocol requirements
        struct TestDocument: FirestoreDocument {
            let id: String
            let createdAt: Date
            let updatedAt: Date
        }

        let now = Date()
        let document = TestDocument(
            id: "test123",
            createdAt: now,
            updatedAt: now
        )

        XCTAssertEqual(document.id, "test123")
        XCTAssertEqual(document.createdAt, now)
        XCTAssertEqual(document.updatedAt, now)
    }

    func testWithTimestampsHelper() {
        struct TestDocument: FirestoreDocument {
            let id: String
            let createdAt: Date
            let updatedAt: Date
        }

        let document = TestDocument.withTimestamps { now in
            TestDocument(id: "test", createdAt: now, updatedAt: now)
        }

        XCTAssertEqual(document.id, "test")
        XCTAssertNotNil(document.createdAt)
        XCTAssertNotNil(document.updatedAt)
    }
}
