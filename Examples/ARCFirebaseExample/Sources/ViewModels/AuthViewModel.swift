//
//  AuthViewModel.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import ARCFirebaseAuth
import ARCFirebaseCrashlytics
import Foundation

// MARK: - AuthViewModel

/// ViewModel responsible for managing authentication state and user actions.
///
/// This ViewModel demonstrates several key patterns:
///
/// 1. **Protocol-based Dependencies**: Uses `AuthProviding`, `AnalyticsProviding`, and
///    `CrashlyticsProviding` protocols for dependency injection and testing.
///
/// 2. **@Observable Pattern**: Uses Swift's Observation framework for reactive UI updates.
///
/// 3. **Centralized State**: Maintains single source of truth for auth state.
///
/// 4. **Analytics Integration**: Tracks all user actions for product insights.
///
/// 5. **Error Recording**: Reports errors to Crashlytics for debugging.
///
/// ## Usage
///
/// ```swift
/// // Production usage
/// let viewModel = AuthViewModel(
///     auth: FirebaseAuthProvider.live,
///     analytics: FirebaseAnalyticsProvider.live,
///     crashlytics: FirebaseCrashlyticsProvider.live
/// )
///
/// // Testing usage
/// let viewModel = AuthViewModel(
///     auth: MockAuthProvider(),
///     analytics: MockAnalyticsProvider(),
///     crashlytics: MockCrashlyticsProvider()
/// )
/// ```
@MainActor
@Observable
final class AuthViewModel {
    // MARK: Private Properties

    /// Authentication provider for sign in/up/out operations.
    private let auth: any AuthProviding

    /// Analytics provider for event tracking.
    private let analytics: any AnalyticsProviding

    /// Crashlytics provider for error recording.
    private let crashlytics: any CrashlyticsProviding

    // MARK: Public State

    /// User's email address for sign in/up forms.
    var email: String = ""

    /// User's password for sign in/up forms.
    var password: String = ""

    /// Indicates if an async operation is in progress.
    private(set) var isLoading: Bool = false

    /// Current error message to display to user.
    private(set) var errorMessage: String?

    /// Currently authenticated user, if any.
    private(set) var currentUser: User?

    /// Whether a user is currently authenticated.
    private(set) var isAuthenticated: Bool = false

    // MARK: Initialization

    /// Creates an AuthViewModel with the specified providers.
    ///
    /// - Parameters:
    ///   - auth: The authentication provider to use.
    ///   - analytics: The analytics provider for event tracking.
    ///   - crashlytics: The crashlytics provider for error recording.
    init(auth: any AuthProviding,
         analytics: any AnalyticsProviding,
         crashlytics: any CrashlyticsProviding = MockCrashlyticsProvider()) {
        self.auth = auth
        self.analytics = analytics
        self.crashlytics = crashlytics

        // Check initial auth state asynchronously
        Task {
            await updateCurrentUser()
        }
    }

    // MARK: Authentication Actions

    /// Attempts to sign in the user with email and password.
    ///
    /// This method demonstrates the complete sign-in flow:
    /// 1. Validate input
    /// 2. Show loading state
    /// 3. Call auth provider
    /// 4. Update local state
    /// 5. Track analytics event
    /// 6. Set user context for Crashlytics
    /// 7. Handle errors gracefully
    func signIn() async {
        // ====================================================================
        // Input Validation
        // ====================================================================
        // Always validate before making network calls.
        guard validateInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            // ================================================================
            // Sign In Operation
            // ================================================================
            let user = try await auth.signIn(email: email,
                                             password: password)

            // Update local state
            currentUser = user
            isAuthenticated = true

            // Clear form fields
            email = ""
            password = ""

            // ================================================================
            // Analytics Tracking
            // ================================================================
            // Track successful sign in for user funnel analysis.
            analytics.logEvent("user_signed_in", parameters: ["method": "email"])

            // Set user ID for analytics attribution
            analytics.setUserID(user.id)

            // ================================================================
            // Crashlytics Context
            // ================================================================
            // Set user ID so crash reports are attributed to specific users.
            // Never use PII (email, name) - only opaque IDs.
            crashlytics.setUserID(user.id)
            crashlytics.log("User signed in successfully")

            print("✅ Sign in successful: \(user.email ?? "unknown")")

        } catch {
            // ================================================================
            // Error Handling
            // ================================================================
            // Show user-friendly message and record error for debugging.
            errorMessage = mapAuthError(error)
            crashlytics.record(error: error)
            print("❌ Sign in failed: \(error)")
        }

        isLoading = false
    }

    /// Creates a new user account with email and password.
    ///
    /// The sign-up flow is similar to sign-in but:
    /// - Creates a new account instead of authenticating existing one
    /// - Uses `.newPassword` text content type for better autofill
    /// - Tracks different analytics event
    func signUp() async {
        guard validateInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await auth.signUp(email: email,
                                             password: password)

            currentUser = user
            isAuthenticated = true

            // Clear form fields
            email = ""
            password = ""

            // Track sign up event (different from sign in for funnel analysis)
            analytics.logEvent("user_signed_up", parameters: ["method": "email"])

            analytics.setUserID(user.id)
            crashlytics.setUserID(user.id)
            crashlytics.log("New user account created")

            print("✅ Sign up successful: \(user.email ?? "unknown")")

        } catch {
            errorMessage = mapAuthError(error)
            crashlytics.record(error: error)
            print("❌ Sign up failed: \(error)")
        }

        isLoading = false
    }

    /// Signs out the current user.
    ///
    /// On sign out:
    /// - Clear local user state
    /// - Clear analytics user ID
    /// - Clear Crashlytics user ID
    /// - Track sign out event
    func signOut() async {
        do {
            try await auth.signOut()

            currentUser = nil
            isAuthenticated = false

            analytics.logEvent("user_signed_out")
            analytics.setUserID(nil)
            crashlytics.clearUserID()
            crashlytics.log("User signed out")

            print("✅ Sign out successful")

        } catch {
            errorMessage = error.localizedDescription
            crashlytics.record(error: error)
            print("❌ Sign out failed: \(error)")
        }
    }

    /// Clears any displayed error message.
    func clearError() {
        errorMessage = nil
    }

    // MARK: Debug Actions

    #if DEBUG
    /// Tests Crashlytics logging functionality.
    func testCrashlyticsLog() {
        crashlytics.log("Test log from ARCFirebase Example App")
        crashlytics.setCustomValue("test_value", forKey: "test_key")
        print("✅ Crashlytics test log sent")
    }

    /// Tests non-fatal error recording.
    func testNonFatalError() {
        let testError = NSError(domain: "com.arclabs.arcfirebase.example",
                                code: 999,
                                userInfo: [NSLocalizedDescriptionKey: "Test non-fatal error"])
        crashlytics.recordNonFatal(error: testError)
        print("✅ Test non-fatal error recorded")
    }

    /// Sets mock authenticated state for previews.
    func mockAuthenticate() {
        currentUser = .mock
        isAuthenticated = true
    }
    #endif
}

// MARK: - Private Helpers

extension AuthViewModel {
    /// Validates email and password input before submission.
    private func validateInput() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }

        // Basic email format validation
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return false
        }

        return true
    }

    /// Updates current user state from auth provider.
    private func updateCurrentUser() async {
        currentUser = await auth.currentUser
        isAuthenticated = await auth.isAuthenticated

        if let user = currentUser {
            analytics.setUserID(user.id)
            crashlytics.setUserID(user.id)
        }
    }

    /// Maps auth errors to user-friendly messages.
    private func mapAuthError(_ error: Error) -> String {
        // In production, you'd check for specific Firebase error codes
        // and provide more helpful messages.
        let description = error.localizedDescription.lowercased()

        if description.contains("password") {
            return "Invalid password. Please try again."
        } else if description.contains("email") {
            return "Invalid email address. Please check and try again."
        } else if description.contains("user not found") {
            return "No account found with this email. Sign up instead?"
        } else if description.contains("already in use") {
            return "This email is already registered. Try signing in."
        } else if description.contains("network") {
            return "Network error. Please check your connection."
        }

        return error.localizedDescription
    }
}
