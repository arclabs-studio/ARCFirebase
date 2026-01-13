//
//  FirebaseCrashlyticsProviderTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import Foundation
import Testing
@testable import ARCFirebaseCrashlytics

@Suite("FirebaseCrashlyticsProvider Tests")
struct FirebaseCrashlyticsProviderTests {
    // MARK: - Mock Provider Tests

    @Test("Mock provider can record error")
    func recordError_withError_tracksCorrectly() {
        let mock = MockCrashlyticsProvider()
        let testError = NSError(domain: "TestDomain", code: 100, userInfo: nil)

        mock.record(error: testError)

        #expect(mock.recordErrorCallCount == 1)
        #expect(mock.recordedErrors.count == 1)
    }

    @Test("Mock provider can record non-fatal error")
    func recordNonFatal_withError_tracksCorrectly() {
        let mock = MockCrashlyticsProvider()
        let testError = NSError(domain: "TestDomain", code: 200, userInfo: nil)

        mock.recordNonFatal(error: testError)

        #expect(mock.recordNonFatalCallCount == 1)
        #expect(mock.recordedNonFatalErrors.count == 1)
    }

    @Test("Mock provider can log messages")
    func log_withMessage_tracksCorrectly() {
        let mock = MockCrashlyticsProvider()
        let message = "User navigated to settings"

        mock.log(message)

        #expect(mock.logCallCount == 1)
        #expect(mock.loggedMessages.first == message)
    }

    @Test("Mock provider can set user ID")
    func setUserID_withValidID_setsCorrectly() {
        let mock = MockCrashlyticsProvider()
        let userID = "user-12345"

        mock.setUserID(userID)

        #expect(mock.setUserIDCallCount == 1)
        #expect(mock.currentUserID == userID)
    }

    @Test("Mock provider can clear user ID")
    func clearUserID_afterSetting_clearsCorrectly() {
        let mock = MockCrashlyticsProvider()
        mock.setUserID("user-12345")

        mock.clearUserID()

        #expect(mock.clearUserIDCallCount == 1)
        #expect(mock.currentUserID == nil)
    }

    @Test("Mock provider can set custom values")
    func setCustomValue_withStringValue_setsCorrectly() {
        let mock = MockCrashlyticsProvider()
        let key = "theme"
        let value = "dark"

        mock.setCustomValue(value, forKey: key)

        #expect(mock.setCustomValueCallCount == 1)
        #expect(mock.customValues[key] as? String == value)
    }

    @Test("Mock provider can track multiple errors")
    func recordError_multipleTimes_tracksAllErrors() {
        let mock = MockCrashlyticsProvider()
        let error1 = NSError(domain: "Domain1", code: 1, userInfo: nil)
        let error2 = NSError(domain: "Domain2", code: 2, userInfo: nil)
        let error3 = NSError(domain: "Domain3", code: 3, userInfo: nil)

        mock.record(error: error1)
        mock.record(error: error2)
        mock.record(error: error3)

        #expect(mock.recordErrorCallCount == 3)
        #expect(mock.recordedErrors.count == 3)
    }

    @Test("Mock provider can log multiple messages")
    func log_multipleTimes_tracksAllMessages() {
        let mock = MockCrashlyticsProvider()

        mock.log("Message 1")
        mock.log("Message 2")
        mock.log("Message 3")

        #expect(mock.logCallCount == 3)
        #expect(mock.loggedMessages.count == 3)
        #expect(mock.loggedMessages == ["Message 1", "Message 2", "Message 3"])
    }

    @Test("Mock provider reset clears all state")
    func reset_afterOperations_clearsAllState() {
        let mock = MockCrashlyticsProvider()

        // Perform various operations
        mock.record(error: NSError(domain: "Test", code: 1, userInfo: nil))
        mock.recordNonFatal(error: NSError(domain: "Test", code: 2, userInfo: nil))
        mock.log("Test message")
        mock.setUserID("user-123")
        mock.setCustomValue("value", forKey: "key")

        // Reset
        mock.reset()

        // Verify all state is cleared
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

    @Test("Mock provider supports integer custom values")
    func setCustomValue_withIntValue_setsCorrectly() {
        let mock = MockCrashlyticsProvider()

        mock.setCustomValue(42, forKey: "retry_count")

        #expect(mock.customValues["retry_count"] as? Int == 42)
    }

    @Test("Mock provider supports boolean custom values")
    func setCustomValue_withBoolValue_setsCorrectly() {
        let mock = MockCrashlyticsProvider()

        mock.setCustomValue(true, forKey: "is_premium")

        #expect(mock.customValues["is_premium"] as? Bool == true)
    }

    // MARK: - Protocol Conformance Tests

    @Test("CrashlyticsProviding protocol exists")
    func protocolExists() {
        let mock: any CrashlyticsProviding = MockCrashlyticsProvider()
        #expect(mock is CrashlyticsProviding)
    }
}
