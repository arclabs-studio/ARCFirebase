import Foundation
import FirebaseAuth

/// Represents an authenticated user.
///
/// This is a simplified, app-specific representation of a Firebase user.
public struct User: Sendable, Identifiable {

    /// The user's unique identifier.
    public let id: String

    /// The user's email address, if available.
    public let email: String?

    /// The user's display name, if available.
    public let displayName: String?

    /// The user's photo URL, if available.
    public let photoURL: URL?

    /// Indicates whether the user's email has been verified.
    public let isEmailVerified: Bool

    /// The date the user was created.
    public let creationDate: Date?

    /// The date the user last signed in.
    public let lastSignInDate: Date?

    // MARK: - Initialization

    /// Creates a user from a Firebase user object.
    ///
    /// - Parameter firebaseUser: The Firebase user to convert.
    public init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        self.displayName = firebaseUser.displayName
        self.photoURL = firebaseUser.photoURL
        self.isEmailVerified = firebaseUser.isEmailVerified
        self.creationDate = firebaseUser.metadata.creationDate
        self.lastSignInDate = firebaseUser.metadata.lastSignInDate
    }
}

// MARK: - CustomStringConvertible

extension User: CustomStringConvertible {
    public var description: String {
        "User(id: \(id), email: \(email ?? "nil"), verified: \(isEmailVerified))"
    }
}
