import ARCFirebaseCore
import ARCLogger
import FirebaseAnalytics
import Foundation

/// Firebase implementation of ``AnalyticsProviding``.
///
/// This is the production analytics provider that uses Firebase Analytics.
/// Implemented as an actor for thread-safe access in concurrent environments.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance
/// let analytics = try FirebaseAnalyticsProvider()
///
/// // Or use the convenience default
/// let analytics = FirebaseAnalyticsProvider.live
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
/// - ``live``
public actor FirebaseAnalyticsProvider: AnalyticsProviding {
    // MARK: - Properties

    private let logger = ARCLogger(subsystem: "com.arclabs-studio.arcfirebase", category: "FirebaseAnalytics")

    // MARK: - Initialization

    /// Creates a Firebase analytics provider.
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init() throws {
        try FirebaseManager.ensureConfigured()
        logger.info("FirebaseAnalyticsProvider initialized")
    }

    // MARK: - AnalyticsProviding Implementation

    /// Firebase Analytics methods are thread-safe and can be called from any context.
    public nonisolated func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    /// Firebase Analytics methods are thread-safe and can be called from any context.
    public nonisolated func logScreenView(_ screenName: String, screenClass: String? = nil) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
    }

    /// Firebase Analytics methods are thread-safe and can be called from any context.
    public nonisolated func setUserProperty(_ name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
    }

    /// Firebase Analytics methods are thread-safe and can be called from any context.
    public nonisolated func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
    }
}

// MARK: - Factory Methods

extension FirebaseAnalyticsProvider {
    /// Creates a new instance with explicit error handling.
    ///
    /// Use this method when you want to handle initialization errors:
    ///
    /// ```swift
    /// do {
    ///     let analytics = try FirebaseAnalyticsProvider.create()
    /// } catch {
    ///     // Handle configuration error
    /// }
    /// ```
    ///
    /// - Returns: A configured ``FirebaseAnalyticsProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create() throws -> FirebaseAnalyticsProvider {
        try FirebaseAnalyticsProvider()
    }

    /// Default live instance for production use.
    ///
    /// - Important: This will crash if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first.
    public static var live: FirebaseAnalyticsProvider {
        do {
            return try create()
        } catch {
            fatalError(
                """
                FirebaseAnalyticsProvider initialization failed.
                Ensure FirebaseManager.shared.configure() is called before accessing .live.
                Error: \(error.localizedDescription)
                """
            )
        }
    }
}
