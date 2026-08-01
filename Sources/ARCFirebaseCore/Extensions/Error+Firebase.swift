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

        case NSURLErrorDomain:
            return .networkError(underlying: self)

        default:
            return .unknown(underlying: self)
        }
    }
}
