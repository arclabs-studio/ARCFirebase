//
//  AppCheckProviding.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import Foundation

/// Protocol defining App Check capabilities.
///
/// Use this protocol for dependency injection to make your code testable
/// and decoupled from Firebase App Check.
///
/// ## Recommended Setup
///
/// Pass an `appCheckProvider` to `FirebaseManager.configure()` at app launch.
/// App Check factory registration is handled automatically — no need to call
/// `configure()` separately:
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
/// }
/// ```
///
/// ## Topics
///
/// ### Configuration
/// - ``configure()``
/// - ``isConfigured``
///
/// ### Token Retrieval
/// - ``getLimitedUseToken()``
///
/// ### Implementations
/// - ``FirebaseAppCheckProvider``
public protocol AppCheckProviding: Sendable {
    /// Registers the App Check provider factory with Firebase.
    ///
    /// - Note: When using `FirebaseManager.configure(appCheckProvider:)` (recommended),
    ///   this method is a no-op — the factory is already registered. Only needed for
    ///   standalone App Check setup without `FirebaseManager`.
    func configure() throws

    /// Returns a limited-use App Check token for a single Cloud Functions call.
    ///
    /// Limited-use tokens are consumed after a single use and are recommended
    /// for Cloud Functions calls to prevent replay attacks.
    ///
    /// - Returns: The App Check token string.
    /// - Throws: ``FirebaseError/appCheckTokenError(underlying:)`` if token retrieval fails.
    func getLimitedUseToken() async throws -> String

    /// Indicates whether the App Check provider has been configured.
    var isConfigured: Bool { get }
}
