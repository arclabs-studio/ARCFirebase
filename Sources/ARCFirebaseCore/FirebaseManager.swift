//
//  FirebaseManager.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import ARCLogger
import FirebaseCore
import Foundation

// MARK: - FirebaseManager

/// Central manager for Firebase configuration and initialization.
///
/// `FirebaseManager` ensures Firebase is configured exactly once and provides
/// utilities for verifying Firebase availability throughout the app.
///
/// ## Topics
///
/// ### Configuration
/// - ``configure()``
/// - ``ensureConfigured()``
/// - ``isConfigured``
///
/// ### Best Practices
/// - <doc:GettingStarted>
/// - <doc:MultiAppSetup>
@MainActor public final class FirebaseManager: FirebaseConfiguring {
    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = FirebaseManager()

    // MARK: - Properties

    private let logger = ARCLogger(subsystem: "com.arclabs-studio.arcfirebase", category: "Firebase")

    /// Indicates whether Firebase has been configured.
    ///
    /// Check this property before using Firebase services if you need to
    /// verify configuration status.
    public private(set) var isConfigured = false

    // MARK: - Initialization

    private init() {}

    // MARK: - FirebaseConfiguring Implementation

    /// Configures Firebase using the GoogleService-Info.plist file in your app bundle.
    ///
    /// Call this method **once** at app launch, typically in your `App` initializer
    /// or `AppDelegate.didFinishLaunching`.
    ///
    /// ```swift
    /// @main
    /// struct FavResApp: App {
    ///     init() {
    ///         FirebaseManager.shared.configure()
    ///     }
    /// }
    /// ```
    ///
    /// - Important: This method must be called before using any Firebase services.
    ///              Calling it multiple times is safe (subsequent calls are ignored).
    ///
    /// - Warning: Your app must include a valid `GoogleService-Info.plist` file.
    public func configure() {
        // Safe to call multiple times - Firebase handles this
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            logger.info("Firebase configured successfully")
        } else {
            logger.debug("Firebase already configured")
        }
        isConfigured = true
    }

    // MARK: - Static Convenience Methods

    /// Static convenience method for configuration.
    ///
    /// Equivalent to calling `FirebaseManager.shared.configure()`.
    public static func configure() {
        shared.configure()
    }

    /// Verifies that Firebase is configured.
    ///
    /// Use this method in your Firebase modules to ensure Firebase was configured
    /// before attempting to use services.
    ///
    /// ```swift
    /// public init() throws {
    ///     try FirebaseManager.ensureConfigured()
    ///     // Safe to use Firebase services now
    /// }
    /// ```
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public nonisolated static func ensureConfigured() throws {
        guard FirebaseApp.app() != nil else {
            throw FirebaseError.notConfigured
        }
    }
}
