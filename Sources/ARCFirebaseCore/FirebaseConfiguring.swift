//
//  FirebaseConfiguring.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import Foundation

// MARK: - FirebaseConfiguring

/// Protocol defining Firebase configuration capabilities.
///
/// Use this protocol for dependency injection to make your code testable
/// and decoupled from the Firebase singleton.
///
/// ## Usage in Production
///
/// ```swift
/// @MainActor
/// class AppCoordinator {
///     private let firebase: FirebaseConfiguring
///
///     init(firebase: FirebaseConfiguring = FirebaseManager.shared) {
///         self.firebase = firebase
///     }
///
///     func setup() {
///         firebase.configure()
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// @MainActor
/// final class MockFirebaseManager: FirebaseConfiguring {
///     var configureCallCount = 0
///     var isConfigured = false
///
///     func configure() {
///         configureCallCount += 1
///         isConfigured = true
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
/// ### Implementations
/// - ``FirebaseManager``
@MainActor public protocol FirebaseConfiguring: AnyObject, Sendable {
    /// Indicates whether Firebase has been configured.
    var isConfigured: Bool { get }

    /// Configures Firebase using the GoogleService-Info.plist file.
    func configure()
}
