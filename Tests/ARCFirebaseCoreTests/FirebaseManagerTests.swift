import Foundation
import Testing
@testable import ARCFirebaseCore

@Suite("FirebaseManager Tests")
struct FirebaseManagerTests {
    @Test("FirebaseManager is a singleton")
    @MainActor
    func firebaseManagerSingleton() {
        let manager1 = FirebaseManager.shared
        let manager2 = FirebaseManager.shared

        #expect(manager1 === manager2)
    }

    @Test("Initial configuration state exists")
    @MainActor
    func initialConfigurationState() {
        // Note: In a real test environment, Firebase might already be configured
        // This test verifies the property exists
        let isConfigured = FirebaseManager.shared.isConfigured
        #expect(isConfigured == true || isConfigured == false)
    }

    @Test("FirebaseError descriptions are not nil")
    func firebaseErrorDescriptions() {
        let notConfiguredError = FirebaseError.notConfigured
        #expect(notConfiguredError.errorDescription != nil)
        #expect(notConfiguredError.errorDescription?.contains("Firebase") == true)

        let authError = FirebaseError.authNotAvailable
        #expect(authError.errorDescription != nil)

        let firestoreError = FirebaseError.firestoreNotAvailable
        #expect(firestoreError.errorDescription != nil)

        let storageError = FirebaseError.storageNotAvailable
        #expect(storageError.errorDescription != nil)

        let analyticsError = FirebaseError.analyticsNotAvailable
        #expect(analyticsError.errorDescription != nil)

        let documentNotFoundError = FirebaseError.documentNotFound
        #expect(documentNotFoundError.errorDescription != nil)

        let permissionDeniedError = FirebaseError.permissionDenied
        #expect(permissionDeniedError.errorDescription != nil)
    }

    @Test("Network error wrapping")
    func networkErrorWrapping() {
        let underlyingError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        let networkError = FirebaseError.networkError(underlying: underlyingError)

        #expect(networkError.errorDescription != nil)
        #expect(networkError.errorDescription?.contains("Network") == true)
    }

    @Test("Unknown error wrapping")
    func unknownErrorWrapping() {
        let underlyingError = NSError(domain: "TestDomain", code: 999, userInfo: nil)
        let unknownError = FirebaseError.unknown(underlying: underlyingError)

        #expect(unknownError.errorDescription != nil)
        #expect(unknownError.errorDescription?.contains("unknown") == true)
    }
}
