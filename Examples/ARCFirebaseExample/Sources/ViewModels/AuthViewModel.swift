import SwiftUI
import ARCFirebaseAuth
import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics

@MainActor
@Observable
final class AuthViewModel {

    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var currentUser: User?

    var isAuthenticated: Bool {
        AuthManager.shared.isAuthenticated
    }

    init() {
        updateCurrentUser()
    }

    // MARK: - Sign In

    func signIn() async {
        guard validateInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await AuthManager.shared.signIn(
                email: email,
                password: password
            )

            currentUser = user

            // Track sign in event
            AnalyticsManager.shared.logEvent("user_signed_in", parameters: [
                "method": "email"
            ])

            // Set user ID for analytics and crashlytics
            AnalyticsManager.shared.setUserID(user.id)
            CrashlyticsManager.shared.setUserID(user.id)

            print("✅ Sign in successful: \(user.email ?? "unknown")")

        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.record(error: error)
            print("❌ Sign in failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Sign Up

    func signUp() async {
        guard validateInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await AuthManager.shared.signUp(
                email: email,
                password: password
            )

            currentUser = user

            // Track sign up event
            AnalyticsManager.shared.logEvent("user_signed_up", parameters: [
                "method": "email"
            ])

            // Set user ID for analytics and crashlytics
            AnalyticsManager.shared.setUserID(user.id)
            CrashlyticsManager.shared.setUserID(user.id)

            print("✅ Sign up successful: \(user.email ?? "unknown")")

        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.record(error: error)
            print("❌ Sign up failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try AuthManager.shared.signOut()
            currentUser = nil

            // Track sign out event
            AnalyticsManager.shared.logEvent("user_signed_out")

            // Clear user ID
            AnalyticsManager.shared.setUserID(nil)
            CrashlyticsManager.shared.setUserID("")

            print("✅ Sign out successful")

        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.record(error: error)
            print("❌ Sign out failed: \(error)")
        }
    }

    // MARK: - Private Helpers

    private func validateInput() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }

        return true
    }

    private func updateCurrentUser() {
        currentUser = AuthManager.shared.currentUser
    }
}
