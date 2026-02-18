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

    private func authError(code: Int) -> FirebaseError {
        switch code {
        case 17_011: .userNotFound        // ERROR_USER_NOT_FOUND
        case 17_009: .permissionDenied    // ERROR_WRONG_PASSWORD
        case 17_020: .networkError(underlying: self) // ERROR_NETWORK_REQUEST_FAILED
        default: .unknown(underlying: self)
        }
    }

    private func storageError(code: Int) -> FirebaseError {
        switch code {
        case -13_010: .documentNotFound // OBJECT_NOT_FOUND
        case -13_021: .permissionDenied // UNAUTHORIZED
        default: .unknown(underlying: self)
        }
    }
}
