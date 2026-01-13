import ARCFirebaseAnalytics
import ARCFirebaseAuth
import ARCFirebaseCore
import ARCFirebaseCrashlytics
import ARCFirebaseStorage
import SwiftUI

@main
struct ARCFirebaseExampleApp: App {
    // MARK: - Providers

    private let auth: FirebaseAuthProvider
    private let analytics: FirebaseAnalyticsProvider
    private let storage: FirebaseStorageProvider

    init() {
        // 1. Configure Firebase Core
        FirebaseManager.configure()

        // 2. Initialize providers
        do {
            auth = try FirebaseAuthProvider()
            analytics = FirebaseAnalyticsProvider()
            storage = try FirebaseStorageProvider()

            // Configure Crashlytics (still uses singleton pattern)
            try CrashlyticsManager.shared.configure()

            print("✅ Firebase configured successfully")
        } catch {
            print("❌ Failed to configure Firebase: \(error)")
            fatalError("Firebase configuration failed: \(error)")
        }

        // 3. Log app opened event
        analytics.logEvent(
            AnalyticsEvent.appOpened,
            parameters: ["platform": "iOS"]
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authProvider, auth)
                .environment(\.analyticsProvider, analytics)
                .environment(\.storageProvider, storage)
        }
    }
}
