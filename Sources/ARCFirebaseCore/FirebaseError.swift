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

    /// A network error occurred.
    case networkError(underlying: Error)

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
            return "Firebase is not configured. Call FirebaseManager.configure() at app launch."
        case .authNotAvailable:
            return "Firebase Authentication is not available."
        case .firestoreNotAvailable:
            return "Firestore database is not available."
        case .storageNotAvailable:
            return "Firebase Storage is not available."
        case .analyticsNotAvailable:
            return "Firebase Analytics is not available."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .documentNotFound:
            return "The requested document was not found."
        case .permissionDenied:
            return "Permission denied. Check your Firestore security rules."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
