//
//  FeatureFlagSnapshot.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-05.
//

import Foundation

// MARK: - FeatureFlagSnapshot

/// An immutable, `Sendable` copy of the active Remote Config values and the registered defaults.
///
/// `RemoteConfig` is not `Sendable`, so ``FirebaseFeatureFlagProvider`` keeps it behind an actor and
/// serves synchronous reads from this snapshot instead. Swapping a whole snapshot at once also means a
/// reader never observes a half-activated config.
///
/// Values are stored the way Remote Config stores them — as UTF-8 `Data` — and the typed reads apply
/// the same conversions as `RemoteConfigValue`, so switching to the snapshot changes no observable value.
struct FeatureFlagSnapshot: Sendable, Equatable {
    // MARK: Properties

    /// Active remote values, keyed by parameter name.
    let remoteValues: [String: Data]

    /// Values registered through ``replacingDefaults(_:)``, keyed by parameter name.
    let defaults: [String: Data]

    // MARK: Initialization

    init(remoteValues: [String: Data] = [:], defaults: [String: Data] = [:]) {
        self.remoteValues = remoteValues
        self.defaults = defaults
    }

    // MARK: Transformations

    /// Returns a copy with the remote values replaced and the defaults kept.
    func replacingRemoteValues(_ values: [String: Data]) -> FeatureFlagSnapshot {
        FeatureFlagSnapshot(remoteValues: values, defaults: defaults)
    }

    /// Returns a copy with the defaults replaced and the remote values kept.
    ///
    /// Mirrors `RemoteConfig.setDefaults(_:)`: the new set replaces the old one, numbers are stored as
    /// their `NSNumber.stringValue`, strings as UTF-8 and data as-is. Values of any other type are dropped.
    func replacingDefaults(_ defaults: [String: any Sendable]) -> FeatureFlagSnapshot {
        FeatureFlagSnapshot(remoteValues: remoteValues, defaults: defaults.compactMapValues(Self.encode))
    }

    // MARK: Reads

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        stringValue(forKey: key).map { ($0 as NSString).boolValue } ?? defaultValue
    }

    func string(forKey key: String, defaultValue: String) -> String {
        stringValue(forKey: key) ?? defaultValue
    }

    func int(forKey key: String, defaultValue: Int) -> Int {
        numberValue(forKey: key)?.intValue ?? defaultValue
    }

    func double(forKey key: String, defaultValue: Double) -> Double {
        numberValue(forKey: key)?.doubleValue ?? defaultValue
    }

    func data(forKey key: String, defaultValue: Data) -> Data {
        value(forKey: key) ?? defaultValue
    }
}

// MARK: - Private

extension FeatureFlagSnapshot {
    /// Remote value first, then the registered default — the precedence Remote Config applies.
    private func value(forKey key: String) -> Data? {
        remoteValues[key] ?? defaults[key]
    }

    /// `RemoteConfigValue.stringValue`: UTF-8 decode, empty when the bytes are not valid UTF-8.
    private func stringValue(forKey key: String) -> String? {
        value(forKey: key).map { String(data: $0, encoding: .utf8) ?? "" }
    }

    /// `RemoteConfigValue.numberValue`: the string parsed as a double.
    private func numberValue(forKey key: String) -> NSNumber? {
        stringValue(forKey: key).map { NSNumber(value: ($0 as NSString).doubleValue) }
    }

    fileprivate static func encode(_ value: any Sendable) -> Data? {
        switch value {
        case let data as Data:
            data
        case let string as String:
            Data(string.utf8)
        case let number as NSNumber:
            Data(number.stringValue.utf8)
        default:
            nil
        }
    }
}
