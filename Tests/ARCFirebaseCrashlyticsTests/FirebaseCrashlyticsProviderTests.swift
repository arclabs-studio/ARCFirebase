//
//  FirebaseCrashlyticsProviderTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
import Testing
@testable import ARCFirebaseCrashlytics

@Suite("FirebaseCrashlyticsProvider Tests") struct FirebaseCrashlyticsProviderTests {
    // MARK: - Mock Provider Tests

    @Test("Mock provider can record error") func recordError_withError_tracksCorrectly() {
        // Given
        let mock = makeSUT()
        let testError = NSError(domain: "TestDomain", code: 100, userInfo: nil)

        // When
        mock.record(error: testError)

        // Then
        #expect(mock.recordErrorCallCount == 1)
        #expect(mock.recordedErrors.count == 1)
    }

    @Test("Mock provider can record non-fatal error") func recordNonFatal_withError_tracksCorrectly() {
        // Given
        let mock = makeSUT()
        let testError = NSError(domain: "TestDomain", code: 200, userInfo: nil)

        // When
        mock.recordNonFatal(error: testError)

        // Then
        #expect(mock.recordNonFatalCallCount == 1)
        #expect(mock.recordedNonFatalErrors.count == 1)
    }

    @Test("Mock provider can log messages") func log_withMessage_tracksCorrectly() {
        // Given
        let mock = makeSUT()
        let message = "User navigated to settings"

        // When
        mock.log(message)

        // Then
        #expect(mock.logCallCount == 1)
        #expect(mock.loggedMessages.first == message)
    }

    @Test("Mock provider can set user ID") func setUserID_withValidID_setsCorrectly() {
        // Given
        let mock = makeSUT()
        let userID = "user-12345"

        // When
        mock.setUserID(userID)

        // Then
        #expect(mock.setUserIDCallCount == 1)
        #expect(mock.currentUserID == userID)
    }

    @Test("Mock provider can clear user ID") func clearUserID_afterSetting_clearsCorrectly() {
        // Given
        let mock = makeSUT()
        mock.setUserID("user-12345")

        // When
        mock.clearUserID()

        // Then
        #expect(mock.clearUserIDCallCount == 1)
        #expect(mock.currentUserID == nil)
    }

    @Test("Mock provider can set custom values") func setCustomValue_withStringValue_setsCorrectly() {
        // Given
        let mock = makeSUT()
        let key = "theme"
        let value = "dark"

        // When
        mock.setCustomValue(value, forKey: key)

        // Then
        #expect(mock.setCustomValueCallCount == 1)
        #expect(mock.customValues[key] as? String == value)
    }

    @Test("Mock provider can track multiple errors") func recordError_multipleTimes_tracksAllErrors() {
        // Given
        let mock = makeSUT()
        let error1 = NSError(domain: "Domain1", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Domain2", code: 2, userInfo: nil)
        let error3 = NSError(domain: "Domain3", code: 3, userInfo: nil)

        // When
        mock.record(error: error1)
        mock.record(error: error2)
        mock.record(error: error3)

        // Then
        #expect(mock.recordErrorCallCount == 3)
        #expect(mock.recordedErrors.count == 3)
    }

    @Test("Mock provider can log multiple messages") func log_multipleTimes_tracksAllMessages() {
        // Given
        let mock = makeSUT()

        // When
        mock.log("Message 1")
        mock.log("Message 2")
        mock.log("Message 3")

        // Then
        #expect(mock.logCallCount == 3)
        #expect(mock.loggedMessages.count == 3)
        #expect(mock.loggedMessages == ["Message 1", "Message 2", "Message 3"])
    }

    @Test("Mock provider reset clears all state") func reset_afterOperations_clearsAllState() {
        // Given
        let mock = makeSUT()
        mock.record(error: NSError(domain: "Test", code: 1, userInfo: nil))
        mock.recordNonFatal(error: NSError(domain: "Test", code: 2, userInfo: nil))
        mock.log("Test message")
        mock.setUserID("user-123")
        mock.setCustomValue("value", forKey: "key")

        // When
        mock.reset()

        // Then
        #expect(mock.recordedErrors.isEmpty)
        #expect(mock.recordedNonFatalErrors.isEmpty)
        #expect(mock.loggedMessages.isEmpty)
        #expect(mock.currentUserID == nil)
        #expect(mock.customValues.isEmpty)
        #expect(mock.recordErrorCallCount == 0)
        #expect(mock.recordNonFatalCallCount == 0)
        #expect(mock.logCallCount == 0)
        #expect(mock.setUserIDCallCount == 0)
        #expect(mock.setCustomValueCallCount == 0)
    }

    @Test("Mock provider supports integer custom values") func setCustomValue_withIntValue_setsCorrectly() {
        // Given
        let mock = makeSUT()

        // When
        mock.setCustomValue(42, forKey: "retry_count")

        // Then
        #expect(mock.customValues["retry_count"] as? Int == 42)
    }

    @Test("Mock provider supports boolean custom values") func setCustomValue_withBoolValue_setsCorrectly() {
        // Given
        let mock = makeSUT()

        // When
        mock.setCustomValue(true, forKey: "is_premium")

        // Then
        #expect(mock.customValues["is_premium"] as? Bool == true)
    }

    // MARK: - Protocol Conformance Tests

    @Test("CrashlyticsProviding protocol is usable via existential") func protocolExists() {
        // Given / When — verify MockCrashlyticsProvider satisfies the protocol existential
        let mock: any CrashlyticsProviding = MockCrashlyticsProvider()
        mock.log("protocol check")

        // Then — if we reach here, the protocol contract is satisfied
        #expect(Bool(true))
    }

    // MARK: - Helpers

    private func makeSUT() -> MockCrashlyticsProvider {
        MockCrashlyticsProvider()
    }
}
