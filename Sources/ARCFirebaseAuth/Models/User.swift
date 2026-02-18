//
//  User.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import Foundation

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

    /// Creates a user with all properties.
    ///
    /// - Parameters:
    ///   - id: The user's unique identifier.
    ///   - email: The user's email address.
    ///   - displayName: The user's display name.
    ///   - photoURL: The user's photo URL.
    ///   - isEmailVerified: Whether the email is verified.
    ///   - creationDate: The date the user was created.
    ///   - lastSignInDate: The date of last sign in.
    public init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: URL? = nil,
        isEmailVerified: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isEmailVerified = isEmailVerified
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
}

// MARK: - CustomStringConvertible

extension User: CustomStringConvertible {
    public var description: String {
        "User(id: \(id), email: \(email ?? "nil"), verified: \(isEmailVerified))"
    }
}
