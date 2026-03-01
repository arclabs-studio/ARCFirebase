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
public struct User: Sendable, Identifiable, Equatable {
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

    /// The primary authentication provider ID (e.g., "password", "google.com", "apple.com").
    public let providerID: String?

    /// The IDs of all linked authentication providers.
    public let linkedProviderIDs: [String]

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
    ///   - providerID: The primary authentication provider ID.
    ///   - linkedProviderIDs: The IDs of all linked authentication providers.
    public init(id: String,
                email: String? = nil,
                displayName: String? = nil,
                photoURL: URL? = nil,
                isEmailVerified: Bool = false,
                creationDate: Date? = nil,
                lastSignInDate: Date? = nil,
                providerID: String? = nil,
                linkedProviderIDs: [String] = []) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isEmailVerified = isEmailVerified
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.providerID = providerID
        self.linkedProviderIDs = linkedProviderIDs
    }
}

// MARK: - CustomStringConvertible

extension User: CustomStringConvertible {
    public var description: String {
        "User(id: \(id), email: \(email ?? "nil"), verified: \(isEmailVerified), provider: \(providerID ?? "nil"))"
    }
}
