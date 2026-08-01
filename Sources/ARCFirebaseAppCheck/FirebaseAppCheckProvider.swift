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
/// `@unchecked Sendable` rationale: `_isConfigured` is a `var Bool` so the class
/// is not statically `Sendable`. Mutation contract: set exactly once during
/// `configure()` (called at app launch, before any other thread reads it) and
/// read-only thereafter. Boolean writes are word-atomic on supported platforms,
/// and the read path (`isConfigured`) only ever observes `false → true`. No
/// reordering hazard is introduced because callers never use `isConfigured` to
/// gate concurrent state.
public final class FirebaseAppCheckProvider: AppCheckProviding, @unchecked Sendable {
    // MARK: - Properties

    private let configuration: AppCheckConfiguration
    private let logger = ARCLogger(subsystem: ARCFirebaseLogSubsystem.current, category: "AppCheck")
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
    /// - Warning: Prefer `FirebaseManager.configure(appCheckProvider:)`. If that path was
    ///   already taken, this method is a **silent no-op** (the factory was registered earlier
    ///   and Firebase is already initialized). Calling it later cannot change the registered
    ///   factory — App Check factories must be installed **before** `FirebaseApp.configure()`.
    /// - Note: When taking this standalone path, you must call `configure()` **before**
    ///   `FirebaseManager.configure()` (or `FirebaseApp.configure()`), otherwise the factory
    ///   registration is skipped and `isConfigured` reflects only the discovery, not a fresh
    ///   registration.
    /// - Important: Tests should use a mock conforming to ``AppCheckProviding`` rather than
    ///   calling the live `configure()` repeatedly.
    public func configure() throws {
        // If Firebase is already configured, App Check factory was registered by FirebaseManager
        // (or by an earlier call). Re-registering is impossible at this point.
        guard FirebaseApp.app() == nil else {
            logger.info("""
            AppCheck factory registration skipped: Firebase already initialized. \
            Use FirebaseManager.configure(appCheckProvider:) to install factories \
            before Firebase setup.
            """)
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
    ///
    /// - Important: Production-only. Tests should use ``create(configuration:)`` with a
    ///   debug-mode configuration, or a mock conforming to ``AppCheckProviding``.
    public static var live: FirebaseAppCheckProvider {
        create()
    }
}
