//
//  FeatureFlagSnapshotTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-05.
//

import Foundation
import Testing
@testable import ARCFirebaseFeatureFlags

@Suite("FeatureFlagSnapshot Tests", .tags(.unit)) struct FeatureFlagSnapshotTests {
    // MARK: - Precedence

    @Test("Remote value wins over a registered default for every accessor", .tags(.critical))
    func read_precedence_remoteBeatsRegisteredDefault() {
        // Given
        let sut = makeSUT(remoteValues: ["bool": Data("1".utf8),
                                         "string": Data("remote".utf8),
                                         "int": Data("7".utf8),
                                         "double": Data("7.5".utf8),
                                         "data": Data("remote-bytes".utf8)],
                          defaults: ["bool": Data("0".utf8),
                                     "string": Data("default".utf8),
                                     "int": Data("1".utf8),
                                     "double": Data("1.5".utf8),
                                     "data": Data("default-bytes".utf8)])

        // Then
        #expect(sut.bool(forKey: "bool", defaultValue: false) == true)
        #expect(sut.string(forKey: "string", defaultValue: "caller") == "remote")
        #expect(sut.int(forKey: "int", defaultValue: 99) == 7)
        #expect(sut.double(forKey: "double", defaultValue: 99.9) == 7.5)
        #expect(sut.data(forKey: "data", defaultValue: Data("caller-bytes".utf8)) == Data("remote-bytes".utf8))
    }

    @Test("A registered default wins over the caller-supplied default when no remote value exists", .tags(.critical))
    func read_precedence_registeredDefaultBeatsCallerSuppliedDefault() {
        // Given
        let sut = makeSUT(defaults: ["bool": Data("1".utf8),
                                     "string": Data("default".utf8),
                                     "int": Data("5".utf8),
                                     "double": Data("5.5".utf8),
                                     "data": Data("default-bytes".utf8)])

        // Then
        #expect(sut.bool(forKey: "bool", defaultValue: false) == true)
        #expect(sut.string(forKey: "string", defaultValue: "caller") == "default")
        #expect(sut.int(forKey: "int", defaultValue: 99) == 5)
        #expect(sut.double(forKey: "double", defaultValue: 99.9) == 5.5)
        #expect(sut.data(forKey: "data", defaultValue: Data("caller-bytes".utf8)) == Data("default-bytes".utf8))
    }

    @Test("The caller-supplied default is used when the key exists nowhere", .tags(.critical))
    func read_precedence_callerSuppliedDefaultUsedWhenKeyAbsent() {
        // Given
        let sut = makeSUT()

        // Then
        #expect(sut.bool(forKey: "missing", defaultValue: true) == true)
        #expect(sut.string(forKey: "missing", defaultValue: "caller") == "caller")
        #expect(sut.int(forKey: "missing", defaultValue: 42) == 42)
        #expect(sut.double(forKey: "missing", defaultValue: 4.2) == 4.2)
        #expect(sut.data(forKey: "missing", defaultValue: Data("caller-bytes".utf8)) == Data("caller-bytes".utf8))
    }

    // MARK: - Bool Conversion Table

    @Test("boolValue follows RemoteConfigValue's (string as NSString).boolValue semantics",
          arguments: [(stored: "true", expected: true),
                      (stored: "TRUE", expected: true),
                      (stored: "yes", expected: true),
                      (stored: "1", expected: true),
                      (stored: "  Y", expected: true),
                      (stored: "false", expected: false),
                      (stored: "0", expected: false),
                      (stored: "no", expected: false),
                      (stored: "", expected: false),
                      (stored: "abc", expected: false)])
    func boolValue_matchesNSStringBoolValueSemantics(_ testCase: (stored: String, expected: Bool)) {
        // Given
        let sut = makeSUT(remoteValues: ["flag": Data(testCase.stored.utf8)])

        // Then — the caller default is the opposite of what's expected, so a wrong fallback would fail too
        #expect(sut.bool(forKey: "flag", defaultValue: !testCase.expected) == testCase.expected)
    }

    // MARK: - Number Conversion Tables

    @Test("intValue truncates toward zero like NSNumber.intValue, and non-numeric strings read as zero",
          arguments: [(stored: "42.9", expected: 42),
                      (stored: "-3.7", expected: -3),
                      (stored: "abc", expected: 0),
                      (stored: "10", expected: 10),
                      (stored: "-10.9", expected: -10)])
    func intValue_truncatesTowardZeroLikeNumberValueIntValue(_ testCase: (stored: String, expected: Int)) {
        // Given
        let sut = makeSUT(remoteValues: ["n": Data(testCase.stored.utf8)])

        // Then
        #expect(sut.int(forKey: "n", defaultValue: 999) == testCase.expected)
    }

    @Test("doubleValue parses the numeric string, or is zero when the string is non-numeric",
          arguments: [(stored: "42.9", expected: 42.9),
                      (stored: "-3.7", expected: -3.7),
                      (stored: "abc", expected: 0.0),
                      (stored: "10", expected: 10.0)])
    func doubleValue_parsesNumericStringOrZero(_ testCase: (stored: String, expected: Double)) {
        // Given
        let sut = makeSUT(remoteValues: ["n": Data(testCase.stored.utf8)])

        // Then
        #expect(sut.double(forKey: "n", defaultValue: 999.9) == testCase.expected)
    }

    // MARK: - UTF-8 Decoding Edge Cases

    @Test("Invalid UTF-8 remote data makes string reads return empty, not the caller default", .tags(.critical))
    func stringValue_withInvalidUTF8RemoteData_returnsEmptyNotCallerDefault() {
        // Given — 0xFF is never a valid UTF-8 byte on its own
        let sut = makeSUT(remoteValues: ["key": Data([0xFF])])

        // Then
        #expect(sut.string(forKey: "key", defaultValue: "fallback").isEmpty)
    }

    @Test("data(forKey:) returns the raw bytes even when they are not valid UTF-8")
    func dataValue_returnsRawBytesEvenWhenNotValidUTF8() {
        // Given
        let bytes = Data([0xFF, 0x00, 0x10])
        let sut = makeSUT(remoteValues: ["key": bytes])

        // Then
        #expect(sut.data(forKey: "key", defaultValue: Data()) == bytes)
    }

    // MARK: - replacingRemoteValues / replacingDefaults Independence

    @Test("replacingRemoteValues keeps the existing defaults unchanged")
    func replacingRemoteValues_keepsExistingDefaults() {
        // Given
        let defaults = ["x": Data("1".utf8)]
        let sut = makeSUT(remoteValues: ["old": Data("old".utf8)], defaults: defaults)
        let newRemote = ["new": Data("new".utf8)]

        // When
        let result = sut.replacingRemoteValues(newRemote)

        // Then
        #expect(result.defaults == defaults)
        #expect(result.remoteValues == newRemote)
    }

    @Test("replacingDefaults keeps the existing remote values unchanged")
    func replacingDefaults_keepsExistingRemoteValues() {
        // Given
        let remote = ["r": Data("v".utf8)]
        let sut = makeSUT(remoteValues: remote, defaults: ["old": Data("x".utf8)])

        // When
        let result = sut.replacingDefaults(["new": 1])

        // Then
        #expect(result.remoteValues == remote)
    }

    @Test("replacingDefaults replaces the whole defaults set instead of merging into it", .tags(.critical))
    func replacingDefaults_replacesEntireSetRatherThanMerging() {
        // Given
        let sut = makeSUT(defaults: ["a": Data("1".utf8), "b": Data("2".utf8)])

        // When
        let result = sut.replacingDefaults(["c": 3])

        // Then
        #expect(Set(result.defaults.keys) == ["c"])
    }

    // MARK: - Defaults Encoding

    @Test("Bool default values are encoded as NSNumber.stringValue UTF-8 bytes")
    func replacingDefaults_encodesBoolAsNSNumberStringValue() {
        // Given
        let sut = makeSUT()

        // When
        let result = sut.replacingDefaults(["on": true, "off": false])

        // Then
        #expect(result.defaults["on"] == Data("1".utf8))
        #expect(result.defaults["off"] == Data("0".utf8))
    }

    @Test("Int default values are encoded as NSNumber.stringValue UTF-8 bytes")
    func replacingDefaults_encodesIntAsNSNumberStringValue() {
        // Given
        let sut = makeSUT()

        // When
        let result = sut.replacingDefaults(["count": 10, "offset": -3])

        // Then
        #expect(result.defaults["count"] == Data("10".utf8))
        #expect(result.defaults["offset"] == Data("-3".utf8))
    }

    @Test("Double default values are encoded as NSNumber.stringValue UTF-8 bytes")
    func replacingDefaults_encodesDoubleAsNSNumberStringValue() {
        // Given
        let sut = makeSUT()

        // When
        let result = sut.replacingDefaults(["threshold": 0.75])

        // Then
        #expect(result.defaults["threshold"] == Data("0.75".utf8))
    }

    @Test("String default values are encoded as their raw UTF-8 bytes")
    func replacingDefaults_encodesStringAsUTF8Bytes() {
        // Given
        let sut = makeSUT()

        // When
        let result = sut.replacingDefaults(["message": "hello"])

        // Then
        #expect(result.defaults["message"] == Data("hello".utf8))
    }

    @Test("Data default values pass through unchanged") func replacingDefaults_encodesDataAsIs() {
        // Given
        let sut = makeSUT()
        let payload = Data([0x01, 0x02, 0xFF])

        // When
        let result = sut.replacingDefaults(["payload": payload])

        // Then
        #expect(result.defaults["payload"] == payload)
    }

    @Test("A default value of an unsupported type (Date) is dropped rather than encoded")
    func replacingDefaults_dropsUnsupportedTypeDate() {
        // Given
        let sut = makeSUT()

        // When
        let result = sut.replacingDefaults(["flag": Date()])

        // Then
        #expect(result.defaults["flag"] == nil)
    }

    @Test("A default value of an unsupported type ([Int]) is dropped rather than encoded")
    func replacingDefaults_dropsUnsupportedTypeArray() {
        // Given
        let sut = makeSUT()

        // When
        let result = sut.replacingDefaults(["list": [1, 2, 3]])

        // Then
        #expect(result.defaults["list"] == nil)
    }

    // MARK: - Helpers

    private func makeSUT(remoteValues: [String: Data] = [:],
                         defaults: [String: Data] = [:]) -> FeatureFlagSnapshot {
        FeatureFlagSnapshot(remoteValues: remoteValues, defaults: defaults)
    }
}
