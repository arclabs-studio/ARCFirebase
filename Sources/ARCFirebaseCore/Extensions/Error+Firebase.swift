//
//  Error+Firebase.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import Foundation

extension Error {
    /// Converts Firebase NSError codes to ``FirebaseError``.
    ///
    /// Use this to wrap Firebase errors in a more Swift-friendly enum.
    ///
    /// ```swift
    /// do {
    ///     try await firebaseOperation()
    /// } catch {
    ///     throw error.asFirebaseError()
    /// }
    /// ```
    public func asFirebaseError() -> FirebaseError {
        let nsError = self as NSError
        switch nsError.domain {
        case "FIRFirestoreErrorDomain": return firestoreError(code: nsError.code)
        case "FIRAuthErrorDomain": return authError(code: nsError.code)
        case "FIRStorageErrorDomain": return storageError(code: nsError.code)
        case "FIRRemoteConfigErrorDomain": return remoteConfigError(code: nsError.code)
        case NSURLErrorDomain: return .networkError(underlying: self)
        default: return .unknown(underlying: self)
        }
    }

    private func firestoreError(code: Int) -> FirebaseError {
        switch code {
        case 5: .documentNotFound // NOT_FOUND
        case 7: .permissionDenied // PERMISSION_DENIED
        default: .unknown(underlying: self)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func authError(code: Int) -> FirebaseError {
        switch code {
        case 17004: .invalidCredential // ERROR_INVALID_CREDENTIAL
        case 17007: .emailAlreadyInUse // ERROR_EMAIL_ALREADY_IN_USE
        case 17008: .invalidEmail // ERROR_INVALID_EMAIL
        case 17009: .permissionDenied // ERROR_WRONG_PASSWORD
        case 17011: .userNotFound // ERROR_USER_NOT_FOUND
        case 17012: .noSuchProvider // ERROR_NO_SUCH_PROVIDER
        case 17014: .requiresRecentLogin // ERROR_REQUIRES_RECENT_LOGIN
        case 17015: .providerAlreadyLinked // ERROR_PROVIDER_ALREADY_LINKED
        case 17016: .weakPassword // ERROR_WEAK_PASSWORD
        case 17020: .networkError(underlying: self) // ERROR_NETWORK_REQUEST_FAILED
        case 17026: .accountExistsWithDifferentCredential // ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL
        default: .unknown(underlying: self)
        }
    }

    private func storageError(code: Int) -> FirebaseError {
        switch code {
        case -13010: .documentNotFound // OBJECT_NOT_FOUND
        case -13021: .permissionDenied // UNAUTHORIZED
        default: .unknown(underlying: self)
        }
    }

    private func remoteConfigError(code: Int) -> FirebaseError {
        switch code {
        case 8003: .fetchThrottled // THROTTLED
        default: .unknown(underlying: self)
        }
    }
}
