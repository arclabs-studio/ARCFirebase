import SwiftUI
import ARCFirebaseCore
import ARCFirebaseAuth
import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics

@main
struct ARCFirebaseExampleApp: App {

    init() {
        configureFirebase()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    // MARK: - Firebase Configuration

    private func configureFirebase() {
        // 1. Configure Firebase Core
        FirebaseManager.configure()

        // 2. Configure Firebase Services
        do {
            try AuthManager.shared.configure()
            try AnalyticsManager.shared.configure()
            try CrashlyticsManager.shared.configure()

            print("✅ Firebase configured successfully")
        } catch {
            print("❌ Failed to configure Firebase: \(error)")
        }

        // 3. Log app opened event
        AnalyticsManager.shared.logEvent(
            AnalyticsEvent.appOpened,
            parameters: ["platform": "iOS"]
        )
    }
}
