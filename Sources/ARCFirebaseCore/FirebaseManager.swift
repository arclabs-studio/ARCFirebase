import Foundation
import FirebaseCore
import ARCLogger

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
public final class FirebaseManager {

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = FirebaseManager()

    // MARK: - Properties

    private let logger = ARCLogger(category: "Firebase")

    /// Indicates whether Firebase has been configured.
    ///
    /// Check this property before using Firebase services if you need to
    /// verify configuration status.
    public private(set) var isConfigured = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Configures Firebase using the GoogleService-Info.plist file in your app bundle.
    ///
    /// Call this method **once** at app launch, typically in your `App` initializer
    /// or `AppDelegate.didFinishLaunching`.
    ///
    /// ```swift
    /// @main
    /// struct FavResApp: App {
    ///     init() {
    ///         FirebaseManager.configure()
    ///     }
    /// }
    /// ```
    ///
    /// - Important: This method must be called before using any Firebase services.
    ///              Calling it multiple times is safe (subsequent calls are ignored).
    ///
    /// - Warning: Your app must include a valid `GoogleService-Info.plist` file.
    public static func configure() {
        // Safe to call multiple times - Firebase handles this
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            shared.isConfigured = true
            shared.logger.info("Firebase configured successfully")
        } else {
            shared.logger.debug("Firebase already configured")
        }
    }

    /// Verifies that Firebase is configured.
    ///
    /// Use this method in your Firebase modules to ensure Firebase was configured
    /// before attempting to use services.
    ///
    /// ```swift
    /// public init() throws {
    ///     try FirebaseManager.shared.ensureConfigured()
    ///     // Safe to use Firebase services now
    /// }
    /// ```
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public func ensureConfigured() throws {
        guard FirebaseApp.app() != nil else {
            logger.error("Firebase not configured. Call FirebaseManager.configure() first.")
            throw FirebaseError.notConfigured
        }
        isConfigured = true
    }
}
