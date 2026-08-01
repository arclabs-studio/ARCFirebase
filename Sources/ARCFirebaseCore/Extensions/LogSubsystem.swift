//
//  LogSubsystem.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-05-19.
//

import Foundation

/// Derives the os_log/Logger subsystem string for ARCFirebase providers.
///
/// At runtime the value is `"<bundleIdentifier>.arcfirebase"` so log streams
/// are scoped to the host app. Falls back to a fixed identifier when no
/// bundle identifier is available (tests, command-line tools).
public enum ARCFirebaseLogSubsystem {
    /// Default subsystem string used by ARCFirebase loggers.
    public static var current: String {
        if let bid = Bundle.main.bundleIdentifier, !bid.isEmpty {
            return "\(bid).arcfirebase"
        }
        return "com.arclabs-studio.arcfirebase"
    }
}
