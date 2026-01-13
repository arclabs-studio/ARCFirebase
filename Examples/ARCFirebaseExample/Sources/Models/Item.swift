import Foundation
import ARCFirebasePersistence

/// Example model representing an item in Firestore
struct Item: FirestoreDocument, Sendable {
    let id: String
    let title: String
    let description: String
    let createdAt: Date
    let updatedAt: Date
    let userId: String

    /// Create a new item with timestamps
    static func create(
        title: String,
        description: String,
        userId: String
    ) -> Item {
        Item.withTimestamps { now in
            Item(
                id: UUID().uuidString,
                title: title,
                description: description,
                createdAt: now,
                updatedAt: now,
                userId: userId
            )
        }
    }
}
