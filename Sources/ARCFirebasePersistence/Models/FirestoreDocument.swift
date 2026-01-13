import Foundation

/// Protocol for Firestore document models.
///
/// Conform your models to this protocol to work seamlessly with ``FirestoreRepository``.
///
/// ```swift
/// struct Restaurant: FirestoreDocument {
///     let id: String
///     let name: String
///     let category: String
///     let createdAt: Date
///     let updatedAt: Date
/// }
/// ```
public protocol FirestoreDocument: Identifiable, Codable where ID == String {

    /// The document's creation timestamp.
    var createdAt: Date { get }

    /// The document's last update timestamp.
    var updatedAt: Date { get }
}

/// Default implementation for timestamp handling.
public extension FirestoreDocument {

    /// Creates timestamps for a new document.
    static func withTimestamps<T: FirestoreDocument>(_ transform: (Date) -> T) -> T {
        let now = Date()
        return transform(now)
    }
}
