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

    /// Remote Config service is not available.
    case remoteConfigNotAvailable

    /// Remote Config fetch was throttled by the server.
    case fetchThrottled

    /// A network error occurred.
    case networkError(underlying: Error)

    /// The requested user was not found.
    case userNotFound

    /// The requested document was not found.
    case documentNotFound

    /// Permission denied for the requested operation.
    case permissionDenied

    /// The email address is already in use by another account.
    case emailAlreadyInUse

    /// The email address is malformed.
    case invalidEmail

    /// The password does not meet strength requirements.
    case weakPassword

    /// The operation requires recent authentication. Re-authenticate and try again.
    case requiresRecentLogin

    /// The provider is already linked to this account.
    case providerAlreadyLinked

    /// The user is not linked to the specified provider.
    case noSuchProvider

    /// The supplied auth credential is invalid or has expired.
    case invalidCredential

    /// An account already exists with a different credential for this email.
    case accountExistsWithDifferentCredential

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
        case .remoteConfigNotAvailable:
            "Firebase Remote Config is not available."
        case .fetchThrottled:
            "Remote Config fetch was throttled. Try again later."
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case .userNotFound:
            "The requested user was not found."
        case .documentNotFound:
            "The requested document was not found."
        case .permissionDenied:
            "Permission denied. Check your Firestore security rules."
        case .emailAlreadyInUse:
            "The email address is already in use by another account."
        case .invalidEmail:
            "The email address is malformed."
        case .weakPassword:
            "The password does not meet strength requirements."
        case .requiresRecentLogin:
            "This operation requires recent authentication. Please sign in again."
        case .providerAlreadyLinked:
            "This provider is already linked to your account."
        case .noSuchProvider:
            "The user is not linked to the specified provider."
        case .invalidCredential:
            "The supplied auth credential is invalid or has expired."
        case .accountExistsWithDifferentCredential:
            "An account already exists with a different credential for this email."
        case let .unknown(error):
            "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
