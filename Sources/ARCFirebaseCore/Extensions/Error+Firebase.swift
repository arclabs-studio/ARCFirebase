import FirebaseCore
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
        case "FIRFirestoreErrorDomain":
            switch nsError.code {
            case 5: // NOT_FOUND
                return .documentNotFound
            case 7: // PERMISSION_DENIED
                return .permissionDenied
            default:
                return .unknown(underlying: self)
            }

        case "FIRAuthErrorDomain":
            switch nsError.code {
            case 17_011: // ERROR_USER_NOT_FOUND
                return .userNotFound
            case 17_009: // ERROR_WRONG_PASSWORD
                return .permissionDenied
            case 17_020: // ERROR_NETWORK_REQUEST_FAILED
                return .networkError(underlying: self)
            default:
                return .unknown(underlying: self)
            }

        case "FIRStorageErrorDomain":
            switch nsError.code {
            case -13_010: // OBJECT_NOT_FOUND
                return .documentNotFound
            case -13_021: // UNAUTHORIZED
                return .permissionDenied
            default:
                return .unknown(underlying: self)
            }

        case NSURLErrorDomain:
            return .networkError(underlying: self)

        default:
            return .unknown(underlying: self)
        }
    }
}
