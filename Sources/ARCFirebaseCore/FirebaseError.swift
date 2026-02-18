//
//  FirebaseError.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import Foundation

/// Errors that can occur when using Firebase services.
///
/// All Firebase modules use this error type for consistency.
public enum FirebaseError: LocalizedError {
    /// Firebase was not configured before attempting to use it.
    ///
    /// **Solution**: Call ``FirebaseManager/configure()`` at app launch.
    case notConfigured

    /// Authentication service is not available.
    case authNotAvailable

    /// Firestore database is not available.
    case firestoreNotAvailable

    /// Storage service is not available.
    case storageNotAvailable

    /// Analytics service is not available.
    case analyticsNotAvailable

    /// AI service is not available.
    case aiNotAvailable

    /// A network error occurred.
    case networkError(underlying: Error)

    /// The requested user was not found.
    case userNotFound

    /// The requested document was not found.
    case documentNotFound

    /// Permission denied for the requested operation.
    case permissionDenied

    /// An unknown error occurred.
    case unknown(underlying: Error)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Firebase is not configured. Call FirebaseManager.configure() at app launch."
        case .authNotAvailable:
            "Firebase Authentication is not available."
        case .firestoreNotAvailable:
            "Firestore database is not available."
        case .storageNotAvailable:
            "Firebase Storage is not available."
        case .analyticsNotAvailable:
            "Firebase Analytics is not available."
        case .aiNotAvailable:
            "Firebase AI is not available."
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case .userNotFound:
            "The requested user was not found."
        case .documentNotFound:
            "The requested document was not found."
        case .permissionDenied:
            "Permission denied. Check your Firestore security rules."
        case let .unknown(error):
            "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
