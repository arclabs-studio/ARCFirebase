//
//  FirebaseAppCheckProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseAppCheck
import FirebaseCore
import Foundation

/// Firebase implementation of ``AppCheckProviding``.
///
/// This is the production App Check provider that verifies request integrity.
///
/// ## Recommended Setup
///
/// Use `FirebaseManager.configure(appCheckProvider:)` to set up App Check as part
/// of normal Firebase initialization — no need to call `configure()` separately:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         #if DEBUG
///         FirebaseManager.shared.configure(appCheckProvider: .debug)
///         #else
///         FirebaseManager.shared.configure(appCheckProvider: .appAttest)
///         #endif
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.appCheckProvider, try? FirebaseAppCheckProvider())
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
/// - ``init(configuration:)``
/// - ``live``
/// - ``create(configuration:)``
///
/// ### AppCheckProviding Implementation
/// - ``configure()``
/// - ``getLimitedUseToken()``
/// - ``isConfigured``
public final class FirebaseAppCheckProvider: AppCheckProviding, @unchecked Sendable {
    // MARK: - Properties

    private let configuration: AppCheckConfiguration
    private let logger = ARCLogger(subsystem: "com.arclabs-studio.arcfirebase", category: "AppCheck")
    private var _isConfigured = false

    // MARK: - Initialization

    /// Creates an App Check provider, verifying Firebase is already configured.
    ///
    /// Use this initializer when `FirebaseManager.configure(appCheckProvider:)` has
    /// already been called at app launch (the recommended approach).
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if `FirebaseManager.configure()` hasn't been called yet.
    public init() throws {
        configuration = .default
        try FirebaseManager.ensureConfigured()
        _isConfigured = true
    }

    /// Creates an App Check provider with the given configuration.
    ///
    /// - Parameter configuration: The App Check configuration. Defaults to ``AppCheckConfiguration/default``.
    public init(configuration: AppCheckConfiguration) {
        self.configuration = configuration
    }

    // MARK: - AppCheckProviding Implementation

    /// Whether the App Check provider factory has been registered.
    public var isConfigured: Bool {
        _isConfigured
    }

    /// Registers the App Check provider factory with Firebase.
    ///
    /// - Note: This is a no-op when `FirebaseManager.configure(appCheckProvider:)` has already
    ///   been called (the recommended path). The factory is already registered by `FirebaseManager`.
    ///   Only call this manually if you need standalone App Check setup without `FirebaseManager`.
    /// - Important: If calling manually, call this **before** `FirebaseManager.configure()`.
    public func configure() throws {
        // If Firebase is already configured, App Check factory was registered by FirebaseManager.
        // Registering it again would be a no-op at best and confusing at worst.
        guard FirebaseApp.app() == nil else {
            logger.debug("AppCheck already configured via FirebaseManager — skipping factory registration")
            _isConfigured = true
            return
        }

        let factory: any AppCheckProviderFactory
        if configuration.isDebug {
            factory = AppCheckDebugProviderFactory()
            logger.info("AppCheck configured with debug provider")
        } else {
            factory = DeviceCheckProviderFactory()
            logger.info("AppCheck configured with DeviceCheck provider")
        }
        AppCheck.setAppCheckProviderFactory(factory)
        _isConfigured = true
    }

    /// Returns a limited-use App Check token for a single Cloud Functions call.
    ///
    /// - Returns: The App Check token string.
    /// - Throws: ``FirebaseError/appCheckTokenError(underlying:)`` if token retrieval fails.
    public func getLimitedUseToken() async throws -> String {
        guard _isConfigured else {
            logger.error("AppCheck not configured — call FirebaseManager.configure(appCheckProvider:) at app launch")
            throw FirebaseError.appCheckNotAvailable
        }

        do {
            let token = try await AppCheck.appCheck().limitedUseToken()
            logger.info("App Check limited-use token retrieved successfully")
            return token.token
        } catch {
            logger.error("Failed to retrieve App Check token: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }
}

// MARK: - Factory Methods

extension FirebaseAppCheckProvider {
    /// Creates a new App Check provider with the given configuration.
    ///
    /// - Parameter configuration: The App Check configuration.
    /// - Returns: A configured ``FirebaseAppCheckProvider`` instance.
    public static func create(configuration: AppCheckConfiguration = .default) -> FirebaseAppCheckProvider {
        FirebaseAppCheckProvider(configuration: configuration)
    }

    /// Default live instance for production use.
    ///
    /// Use after `FirebaseManager.configure(appCheckProvider:)` has been called at app launch.
    /// For a checked initializer that throws if Firebase isn't configured yet, use ``init()`` instead.
    public static var live: FirebaseAppCheckProvider {
        create()
    }
}
