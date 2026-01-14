import Foundation

/// Represents a reference to a file in Firebase Storage.
///
/// Use this to build storage paths in a type-safe way.
///
/// ```swift
/// let reference = StorageReference(
///     bucket: "restaurants",
///     path: "\(restaurantID)/photos/\(photoID).jpg"
/// )
/// ```
public struct StorageReference {
    /// The storage bucket (optional, uses default if nil).
    public let bucket: String?

    /// The file path within the bucket.
    public let path: String

    /// The full storage path.
    public var fullPath: String {
        if let bucket {
            return "\(bucket)/\(path)"
        }
        return path
    }

    // MARK: - Initialization

    /// Creates a storage reference.
    ///
    /// - Parameters:
    ///   - bucket: The storage bucket (uses default if nil).
    ///   - path: The file path.
    public init(bucket: String? = nil, path: String) {
        self.bucket = bucket
        self.path = path
    }
}

// MARK: - Common Paths

extension StorageReference {
    /// Creates a reference for a restaurant photo.
    ///
    /// Path format: `restaurants/{restaurantID}/photos/{filename}`
    public static func restaurantPhoto(restaurantID: String, filename: String) -> StorageReference {
        StorageReference(path: "restaurants/\(restaurantID)/photos/\(filename)")
    }

    /// Creates a reference for a user profile photo.
    ///
    /// Path format: `users/{userID}/profile.jpg`
    public static func userProfilePhoto(userID: String) -> StorageReference {
        StorageReference(path: "users/\(userID)/profile.jpg")
    }
}
