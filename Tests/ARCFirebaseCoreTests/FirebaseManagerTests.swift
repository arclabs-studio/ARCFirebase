import Foundation
import Testing
@testable import ARCFirebaseCore

@Suite("FirebaseManager Tests") struct FirebaseManagerTests {
    @Test("FirebaseManager is a singleton")
    @MainActor func firebaseManagerSingleton() {
        let manager1 = FirebaseManager.shared
        let manager2 = FirebaseManager.shared

        #expect(manager1 === manager2)
    }

    @Test("isConfigured is false before configuration in test environment")
    @MainActor func isConfiguredFalseBeforeConfiguration() {
        // Firebase is never configured in unit tests (no GoogleService-Info.plist)
        #expect(FirebaseManager.shared.isConfigured == false)
    }

    @Test("ensureConfigured throws notConfigured when Firebase is not initialised")
    func ensureConfiguredThrowsWhenNotConfigured() {
        #expect {
            try FirebaseManager.ensureConfigured()
        } throws: { error in
            guard let firebaseError = error as? FirebaseError,
                  case .notConfigured = firebaseError else { return false }
            return true
        }
    }

    @Test("FirebaseError descriptions are not nil") func firebaseErrorDescriptions() {
        let cases: [(FirebaseError, String)] = [(.notConfigured, "Firebase"),
                                                (.authNotAvailable, "Authentication"),
                                                (.firestoreNotAvailable, "Firestore"),
                                                (.storageNotAvailable, "Storage"),
                                                (.analyticsNotAvailable, "Analytics"),
                                                (.aiNotAvailable, "AI"),
                                                (.userNotFound, "user"),
                                                (.documentNotFound, "document"),
                                                (.permissionDenied, "Permission")]

        for (error, keyword) in cases {
            #expect(error.errorDescription != nil, "errorDescription should not be nil for \(error)")
            #expect(error.errorDescription?.localizedCaseInsensitiveContains(keyword) == true,
                    "errorDescription for \(error) should contain '\(keyword)'")
        }
    }

    @Test("Network error wrapping preserves description") func networkErrorWrapping() {
        let underlyingError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        let networkError = FirebaseError.networkError(underlying: underlyingError)

        #expect(networkError.errorDescription != nil)
        #expect(networkError.errorDescription?.contains("Network") == true)
    }

    @Test("Unknown error wrapping preserves description") func unknownErrorWrapping() {
        let underlyingError = NSError(domain: "TestDomain", code: 999, userInfo: nil)
        let unknownError = FirebaseError.unknown(underlying: underlyingError)

        #expect(unknownError.errorDescription != nil)
        #expect(unknownError.errorDescription?.contains("unknown") == true)
    }

    // MARK: - Helpers

    @MainActor private func makeSUT() -> FirebaseManager {
        FirebaseManager.shared
    }
}
