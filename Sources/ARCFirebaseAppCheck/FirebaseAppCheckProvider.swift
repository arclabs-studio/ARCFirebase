//
//  FirebaseAppCheckProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseAppCheck
import Foundation

/// Firebase implementation of ``AppCheckProviding``.
///
/// This is the production App Check provider that verifies request integrity.
///
/// ## Important: Initialization Order
///
/// ``configure()`` **must** be called **before** ``FirebaseManager/configure()``.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance
/// let appCheck = FirebaseAppCheckProvider()
///
/// // Or use the convenience default
/// let appCheck = FirebaseAppCheckProvider.live
/// ```
///
/// ## SwiftUI Integration
///
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         // App Check MUST be configured before Firebase
///         let appCheck = FirebaseAppCheckProvider.live
///         try? appCheck.configure()
///         FirebaseManager.shared.configure()
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.appCheckProvider, FirebaseAppCheckProvider.live)
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
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

    /// Creates an App Check provider with the given configuration.
    ///
    /// - Parameter configuration: The App Check configuration. Defaults to ``AppCheckConfiguration/default``.
    public init(configuration: AppCheckConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: - AppCheckProviding Implementation

    /// Whether the App Check provider factory has been registered.
    public var isConfigured: Bool {
        _isConfigured
    }

    /// Registers the App Check provider factory with Firebase.
    ///
    /// - Important: Call this **before** ``FirebaseManager/configure()``.
    /// - Throws: ``FirebaseError/appCheckNotAvailable`` if registration fails.
    public func configure() throws {
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
            logger.error("AppCheck not configured — call configure() before FirebaseManager.configure()")
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
    /// - Important: Call ``configure()`` on this instance before ``FirebaseManager/configure()``.
    public static var live: FirebaseAppCheckProvider {
        create()
    }
}
