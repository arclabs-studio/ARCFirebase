//
//  Item.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebasePersistence
import Foundation

// MARK: - Item

/// Example model representing an item stored in Firestore.
///
/// This model demonstrates the `FirestoreDocument` protocol which provides:
///
/// 1. **Automatic ID handling**: Document ID maps to `id` property
/// 2. **Timestamp management**: `createdAt` and `updatedAt` are standard fields
/// 3. **Codable conformance**: Automatic encoding/decoding with Firestore
/// 4. **Type-safe queries**: Used with generic `FirestoreRepository<Item>`
///
/// ## FirestoreDocument Requirements
///
/// ```swift
/// protocol FirestoreDocument: Identifiable, Codable where ID == String {
///     var createdAt: Date { get }
///     var updatedAt: Date { get }
/// }
/// ```
///
/// ## Firestore Collection Structure
///
/// ```
/// /items/{itemId}
///     ├── id: String
///     ├── title: String
///     ├── description: String
///     ├── userId: String
///     ├── createdAt: Timestamp
///     └── updatedAt: Timestamp
/// ```
///
/// ## Security Considerations
///
/// The `userId` field enables per-user data isolation in Firestore rules:
///
/// ```javascript
/// match /items/{itemId} {
///     allow read, write: if request.auth.uid == resource.data.userId;
/// }
/// ```
struct Item: FirestoreDocument, Sendable {
    // MARK: Properties

    /// Unique identifier for the item (Firestore document ID).
    let id: String

    /// The item's title (user-provided).
    let title: String

    /// The item's description (user-provided).
    let description: String

    /// Timestamp when the item was created.
    ///
    /// This is set once at creation time and never changes.
    let createdAt: Date

    /// Timestamp when the item was last updated.
    ///
    /// This is updated on every save operation.
    let updatedAt: Date

    /// The ID of the user who owns this item.
    ///
    /// Used for:
    /// - Access control in Firestore rules
    /// - Filtering items by user
    /// - Analytics segmentation
    let userId: String
}

// MARK: - Factory Methods

extension Item {
    /// Creates a new item with automatic timestamps.
    ///
    /// This factory method demonstrates proper timestamp initialization:
    /// - Uses `withTimestamps` helper from `FirestoreDocument`
    /// - Generates a UUID-based document ID
    /// - Sets both timestamps to the current time
    ///
    /// - Parameters:
    ///   - title: The item's title.
    ///   - description: The item's description.
    ///   - userId: The owner's user ID.
    /// - Returns: A new `Item` ready to be saved.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let item = Item.create(
    ///     title: "My Task",
    ///     description: "Complete the Firebase integration",
    ///     userId: currentUser.id
    /// )
    /// try await repository.save(item)
    /// ```
    static func create(title: String,
                       description: String,
                       userId: String) -> Item {
        // ====================================================================
        // Using withTimestamps Helper
        // ====================================================================
        // This helper from FirestoreDocument ensures consistent timestamp
        // handling across all document types in your app.

        Item.withTimestamps { now in
            Item(id: UUID().uuidString,
                 title: title,
                 description: description,
                 createdAt: now,
                 updatedAt: now,
                 userId: userId)
        }
    }
}

// MARK: - Equatable

extension Item: Equatable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}
