//
//  FirebaseErrorMappingTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import Foundation
import Testing
@testable import ARCFirebaseCore

@Suite("Error+Firebase Mapping Tests") struct FirebaseErrorMappingTests {
    // MARK: - Firestore Domain

    @Test("Firestore NOT_FOUND (5) maps to documentNotFound") func firestoreNotFound() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 5, userInfo: nil)
        guard case .documentNotFound = error.asFirebaseError() else {
            Issue.record("Expected .documentNotFound for Firestore NOT_FOUND (5)")
            return
        }
    }

    @Test("Firestore PERMISSION_DENIED (7) maps to permissionDenied") func firestorePermissionDenied() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 7, userInfo: nil)
        guard case .permissionDenied = error.asFirebaseError() else {
            Issue.record("Expected .permissionDenied for Firestore PERMISSION_DENIED (7)")
            return
        }
    }

    @Test("Firestore unknown code maps to unknown") func firestoreUnknownCode() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 999, userInfo: nil)
        guard case .unknown = error.asFirebaseError() else {
            Issue.record("Expected .unknown for unrecognised Firestore error code")
            return
        }
    }

    // MARK: - Auth Domain

    @Test("Auth ERROR_USER_NOT_FOUND (17011) maps to userNotFound") func authUserNotFound() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17011, userInfo: nil)
        guard case .userNotFound = error.asFirebaseError() else {
            Issue.record("Expected .userNotFound for Auth ERROR_USER_NOT_FOUND (17011)")
            return
        }
    }

    @Test("Auth ERROR_WRONG_PASSWORD (17009) maps to permissionDenied") func authWrongPassword() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17009, userInfo: nil)
        guard case .permissionDenied = error.asFirebaseError() else {
            Issue.record("Expected .permissionDenied for Auth ERROR_WRONG_PASSWORD (17009)")
            return
        }
    }

    @Test("Auth ERROR_NETWORK_REQUEST_FAILED (17020) maps to networkError") func authNetworkError() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17020, userInfo: nil)
        guard case .networkError = error.asFirebaseError() else {
            Issue.record("Expected .networkError for Auth ERROR_NETWORK_REQUEST_FAILED (17020)")
            return
        }
    }

    @Test("Auth ERROR_INVALID_CREDENTIAL (17004) maps to invalidCredential") func authInvalidCredential() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17004, userInfo: nil)
        guard case .invalidCredential = error.asFirebaseError() else {
            Issue.record("Expected .invalidCredential for Auth ERROR_INVALID_CREDENTIAL (17004)")
            return
        }
    }

    @Test("Auth ERROR_EMAIL_ALREADY_IN_USE (17007) maps to emailAlreadyInUse") func authEmailAlreadyInUse() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17007, userInfo: nil)
        guard case .emailAlreadyInUse = error.asFirebaseError() else {
            Issue.record("Expected .emailAlreadyInUse for Auth ERROR_EMAIL_ALREADY_IN_USE (17007)")
            return
        }
    }

    @Test("Auth ERROR_INVALID_EMAIL (17008) maps to invalidEmail") func authInvalidEmail() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17008, userInfo: nil)
        guard case .invalidEmail = error.asFirebaseError() else {
            Issue.record("Expected .invalidEmail for Auth ERROR_INVALID_EMAIL (17008)")
            return
        }
    }

    @Test("Auth ERROR_NO_SUCH_PROVIDER (17012) maps to noSuchProvider") func authNoSuchProvider() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17012, userInfo: nil)
        guard case .noSuchProvider = error.asFirebaseError() else {
            Issue.record("Expected .noSuchProvider for Auth ERROR_NO_SUCH_PROVIDER (17012)")
            return
        }
    }

    @Test("Auth ERROR_REQUIRES_RECENT_LOGIN (17014) maps to requiresRecentLogin") func authRequiresRecentLogin() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17014, userInfo: nil)
        guard case .requiresRecentLogin = error.asFirebaseError() else {
            Issue.record("Expected .requiresRecentLogin for Auth ERROR_REQUIRES_RECENT_LOGIN (17014)")
            return
        }
    }

    @Test("Auth ERROR_PROVIDER_ALREADY_LINKED (17015) maps to providerAlreadyLinked") func authProviderAlreadyLinked() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17015, userInfo: nil)
        guard case .providerAlreadyLinked = error.asFirebaseError() else {
            Issue.record("Expected .providerAlreadyLinked for Auth ERROR_PROVIDER_ALREADY_LINKED (17015)")
            return
        }
    }

    @Test("Auth ERROR_WEAK_PASSWORD (17016) maps to weakPassword") func authWeakPassword() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17016, userInfo: nil)
        guard case .weakPassword = error.asFirebaseError() else {
            Issue.record("Expected .weakPassword for Auth error code 17016")
            return
        }
    }

    @Test("Auth ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL (17026) maps to accountExistsWithDifferentCredential")
    func authAccountExistsWithDifferentCredential() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17026, userInfo: nil)
        guard case .accountExistsWithDifferentCredential = error.asFirebaseError() else {
            Issue.record("Expected .accountExistsWithDifferentCredential for Auth error code 17026")
            return
        }
    }

    @Test("Auth unknown code maps to unknown") func authUnknownCode() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 99999, userInfo: nil)
        guard case .unknown = error.asFirebaseError() else {
            Issue.record("Expected .unknown for unrecognised Auth error code")
            return
        }
    }

    // MARK: - Storage Domain

    @Test("Storage OBJECT_NOT_FOUND (-13010) maps to documentNotFound") func storageObjectNotFound() {
        let error = NSError(domain: "FIRStorageErrorDomain", code: -13010, userInfo: nil)
        guard case .documentNotFound = error.asFirebaseError() else {
            Issue.record("Expected .documentNotFound for Storage OBJECT_NOT_FOUND (-13010)")
            return
        }
    }

    @Test("Storage UNAUTHORIZED (-13021) maps to permissionDenied") func storageUnauthorized() {
        let error = NSError(domain: "FIRStorageErrorDomain", code: -13021, userInfo: nil)
        guard case .permissionDenied = error.asFirebaseError() else {
            Issue.record("Expected .permissionDenied for Storage UNAUTHORIZED (-13021)")
            return
        }
    }

    @Test("Storage unknown code maps to unknown") func storageUnknownCode() {
        let error = NSError(domain: "FIRStorageErrorDomain", code: -99999, userInfo: nil)
        guard case .unknown = error.asFirebaseError() else {
            Issue.record("Expected .unknown for unrecognised Storage error code")
            return
        }
    }

    // MARK: - Network Domain

    @Test("NSURLErrorDomain maps to networkError") func nsURLErrorDomain() {
        let error = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        guard case .networkError = error.asFirebaseError() else {
            Issue.record("Expected .networkError for NSURLErrorDomain")
            return
        }
    }

    // MARK: - Unknown Domain

    @Test("Unknown domain maps to unknown") func unknownDomain() {
        let error = NSError(domain: "com.unknown.domain", code: 42, userInfo: nil)
        guard case .unknown = error.asFirebaseError() else {
            Issue.record("Expected .unknown for unrecognised error domain")
            return
        }
    }
}
