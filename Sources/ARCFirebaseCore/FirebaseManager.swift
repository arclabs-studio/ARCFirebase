//
//  FirebaseManager.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import ARCLogger
import FirebaseAppCheck
import FirebaseCore
import Foundation

// MARK: - AppAttestProviderFactory (private)

// Custom factory that wraps `AppAttestProvider` for use with `AppCheck.setAppCheckProviderFactory`.
// Available on iOS 14+, tvOS 15+, watchOS 9+, and visionOS 1+.
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
@available(iOS 14.0, tvOS 15.0, watchOS 9.0, *)
private final class AppAttestProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        AppAttestProvider(app: app)
    }
}
#endif

// MARK: - AppCheckProviderType

/// Specifies which Firebase App Check provider to use at launch.
public enum AppCheckProviderType: Sendable {
    /// Debug provider — prints a token to the console for registration in Firebase Console.
    /// Use in development/simulator environments only.
    case debug
    /// App Attest provider — production attestation. Falls back to DeviceCheck on unsupported devices.
    case appAttest
}

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
@MainActor
public final class FirebaseManager: FirebaseConfiguring {
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

    /// Configures Firebase, optionally installing an App Check provider.
    ///
    /// Call this method **once** at app launch, typically in your `App` initializer
    /// or `AppDelegate.didFinishLaunching`.
    ///
    /// ```swift
    /// @main
    /// struct FavResApp: App {
    ///     init() {
    ///         FirebaseManager.shared.configure(appCheckProvider: .appAttest)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter appCheckProvider: The App Check provider to install **before** Firebase initializes.
    ///   Pass `nil` to skip App Check setup (not recommended for production).
    ///
    /// - Important: App Check must be set before `FirebaseApp.configure()`.
    ///              Calling this method multiple times is safe (subsequent calls are ignored).
    ///
    /// - Warning: Your app must include a valid `GoogleService-Info.plist` file.
    public func configure(appCheckProvider: AppCheckProviderType? = nil) {
        if FirebaseApp.app() == nil {
            if let providerType = appCheckProvider {
                switch providerType {
                case .debug:
                    AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
                case .appAttest:
                    #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                    if #available(iOS 14.0, tvOS 15.0, watchOS 9.0, *) {
                        AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
                    } else {
                        AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
                    }
                    #else
                    AppCheck.setAppCheckProviderFactory(DeviceCheckProviderFactory())
                    #endif
                }
            }
            FirebaseApp.configure()
            logger.info("Firebase configured successfully")
        } else {
            logger.debug("Firebase already configured")
        }
        isConfigured = true
    }

    // MARK: - Protocol Conformance

    /// Configures Firebase without App Check. Satisfies ``FirebaseConfiguring`` protocol.
    ///
    /// Prefer ``configure(appCheckProvider:)`` for new call sites.
    public func configure() {
        configure(appCheckProvider: nil)
    }

    // MARK: - Static Convenience Methods

    /// Static convenience method for configuration with App Check.
    ///
    /// Equivalent to calling `FirebaseManager.shared.configure(appCheckProvider:)`.
    public static func configure(appCheckProvider: AppCheckProviderType? = nil) {
        shared.configure(appCheckProvider: appCheckProvider)
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
