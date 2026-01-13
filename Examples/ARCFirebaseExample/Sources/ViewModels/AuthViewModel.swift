import SwiftUI
import ARCFirebaseAuth
import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics

@MainActor
@Observable
final class AuthViewModel {

    // MARK: - Dependencies

    private let auth: any AuthProviding
    private let analytics: any AnalyticsProviding

    // MARK: - Published State

    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var currentUser: User?
    var isAuthenticated: Bool = false

    init(auth: any AuthProviding, analytics: any AnalyticsProviding) {
        self.auth = auth
        self.analytics = analytics

        Task {
            await updateCurrentUser()
        }
    }

    // MARK: - Sign In

    func signIn() async {
        guard validateInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await auth.signIn(
                email: email,
                password: password
            )

            currentUser = user
            isAuthenticated = true

            // Track sign in event
            analytics.logEvent("user_signed_in", parameters: [
                "method": "email"
            ])

            // Set user ID for analytics and crashlytics
            analytics.setUserID(user.id)
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
            let user = try await auth.signUp(
                email: email,
                password: password
            )

            currentUser = user
            isAuthenticated = true

            // Track sign up event
            analytics.logEvent("user_signed_up", parameters: [
                "method": "email"
            ])

            // Set user ID for analytics and crashlytics
            analytics.setUserID(user.id)
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

    func signOut() async {
        do {
            try await auth.signOut()
            currentUser = nil
            isAuthenticated = false

            // Track sign out event
            analytics.logEvent("user_signed_out")

            // Clear user ID
            analytics.setUserID(nil)
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

    private func updateCurrentUser() async {
        currentUser = await auth.currentUser
        isAuthenticated = await auth.isAuthenticated
    }
}
