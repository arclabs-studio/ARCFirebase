import Foundation
import Testing
@testable import ARCFirebasePersistence

@Suite("FirestoreRepository Tests")
struct FirestoreRepositoryTests {

    struct TestEntity: Identifiable, Codable {
        let id: String
        let name: String
    }

    @Test("FirestoreDocument protocol requirements")
    func firestoreDocumentProtocol() {
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

        #expect(document.id == "test123")
        #expect(document.createdAt == now)
        #expect(document.updatedAt == now)
    }

    @Test("withTimestamps helper creates document with timestamps")
    func withTimestampsHelper() {
        struct TestDocument: FirestoreDocument {
            let id: String
            let createdAt: Date
            let updatedAt: Date
        }

        let document = TestDocument.withTimestamps { now in
            TestDocument(id: "test", createdAt: now, updatedAt: now)
        }

        #expect(document.id == "test")
        #expect(document.createdAt != nil)
        #expect(document.updatedAt != nil)
    }
}
