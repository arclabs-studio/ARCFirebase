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
/// ## Important: Initialization Order
///
/// ``configure()`` **must** be called **before** ``FirebaseManager/configure()``.
/// App Check requires the provider factory to be registered before `FirebaseApp.configure()`.
///
/// ## Usage in Production
///
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         // 1. App Check FIRST
///         let appCheck = FirebaseAppCheckProvider.live
///         try? appCheck.configure()
///         // 2. Then Firebase
///         FirebaseManager.shared.configure()
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
    /// - Important: Call this **before** ``FirebaseManager/configure()``.
    /// - Throws: ``FirebaseError/appCheckNotAvailable`` if registration fails.
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
