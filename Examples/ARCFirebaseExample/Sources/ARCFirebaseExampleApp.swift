//
//  ARCFirebaseExampleApp.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

// ============================================================================
// MARK: - ARCFirebase Example Demo App

// ============================================================================
//
// This demo app showcases all ARCFirebase modules in a didactic way.
// It demonstrates best practices for integrating Firebase in SwiftUI apps.
//
// DEMO MODE:
// The app runs in "demo mode" using mock providers when GoogleService-Info.plist
// is not available. This allows you to explore the UI and architecture without
// setting up a Firebase project.
//
// PRODUCTION MODE:
// Add GoogleService-Info.plist to enable real Firebase integration.
//
// MODULES DEMONSTRATED:
// - ARCFirebaseCore: Firebase configuration and initialization
// - ARCFirebaseAuth: User authentication (sign in/up/out)
// - ARCFirebaseAnalytics: Event tracking and user properties
// - ARCFirebaseCrashlytics: Error recording and crash reporting
// - ARCFirebasePersistence: Firestore CRUD operations
// - ARCFirebaseStorage: File upload/download
//
// ARCHITECTURE PATTERN:
// - Protocol-based providers for dependency injection
// - SwiftUI Environment for provider distribution
// - @Observable ViewModels for state management
// - Mock providers for previews and testing
//
// ============================================================================

import ARCFirebaseAnalytics
import ARCFirebaseAuth
import ARCFirebaseCore
import ARCFirebaseCrashlytics
import ARCFirebaseStorage
import SwiftUI

// MARK: - App Entry Point

/// Main entry point for the ARCFirebase example application.
///
/// This app demonstrates Firebase integration following ARC Labs standards:
///
/// 1. **Firebase Configuration**: Uses `FirebaseManager.configure()` at app launch
/// 2. **Provider Initialization**: Creates typed providers for each Firebase service
/// 3. **Environment Injection**: Distributes providers via SwiftUI Environment
/// 4. **Graceful Fallback**: Uses mock providers when Firebase is not configured
///
/// ## Demo Mode vs Production Mode
///
/// - **Demo Mode**: Runs without `GoogleService-Info.plist` using mock providers
/// - **Production Mode**: Add `GoogleService-Info.plist` for real Firebase
@main
struct ARCFirebaseExampleApp: App {
    // MARK: Private Properties

    /// Authentication provider - manages user sign in/up/out.
    private let authProvider: any AuthProviding

    /// Analytics provider - tracks user events and screen views.
    private let analyticsProvider: any AnalyticsProviding

    /// Storage provider - handles file upload/download.
    private let storageProvider: any StorageProviding

    /// Crashlytics provider - records errors and crashes.
    private let crashlyticsProvider: any CrashlyticsProviding

    /// Indicates if running in demo mode (without Firebase).
    private let isDemoMode: Bool

    // MARK: Initialization

    init() {
        // ====================================================================
        // Initialize providers based on Firebase configuration availability
        // ====================================================================
        let config = Self.initializeProviders()
        authProvider = config.auth
        analyticsProvider = config.analytics
        storageProvider = config.storage
        crashlyticsProvider = config.crashlytics
        isDemoMode = config.isDemoMode
    }

    // MARK: Private Helpers

    /// Initializes all providers based on Firebase configuration availability.
    private static func initializeProviders() -> (
        auth: any AuthProviding,
        analytics: any AnalyticsProviding,
        storage: any StorageProviding,
        crashlytics: any CrashlyticsProviding,
        isDemoMode: Bool
    ) {
        // Check for GoogleService-Info.plist
        let hasFirebaseConfig = Bundle.main.path(
            forResource: "GoogleService-Info",
            ofType: "plist"
        ) != nil

        guard hasFirebaseConfig else {
            // ================================================================
            // DEMO MODE: Use mock providers
            // ================================================================
            print("""
            ℹ️  Running in DEMO MODE

            To enable Firebase integration:
            1. Create a Firebase project at console.firebase.google.com
            2. Add an iOS app with bundle ID: com.arclabs.arcfirebase.example
            3. Download GoogleService-Info.plist
            4. Add it to the Xcode project

            See README.md for detailed instructions.
            """)

            return (
                auth: MockAuthProvider.unauthenticated,
                analytics: MockAnalyticsProvider(),
                storage: MockStorageProvider(),
                crashlytics: MockCrashlyticsProvider(),
                isDemoMode: true
            )
        }

        // ================================================================
        // PRODUCTION MODE: Use real Firebase providers
        // ================================================================
        FirebaseManager.configure()

        do {
            let auth = try FirebaseAuthProvider.create()
            let analytics = try FirebaseAnalyticsProvider.create()
            let storage = try FirebaseStorageProvider.create()
            let crashlytics = try FirebaseCrashlyticsProvider.create()

            print("✅ Firebase configured successfully (Production Mode)")

            // Track app launch
            analytics.logEvent(
                AnalyticsEvent.appOpened,
                parameters: [
                    "platform": "iOS",
                    "mode": "production"
                ]
            )

            return (
                auth: auth,
                analytics: analytics,
                storage: storage,
                crashlytics: crashlytics,
                isDemoMode: false
            )

        } catch {
            // Fall back to demo mode on error
            print("⚠️ Firebase initialization failed, using demo mode: \(error)")
            return (
                auth: MockAuthProvider.unauthenticated,
                analytics: MockAnalyticsProvider(),
                storage: MockStorageProvider(),
                crashlytics: MockCrashlyticsProvider(),
                isDemoMode: true
            )
        }
    }

    // MARK: Scene

    var body: some Scene {
        WindowGroup {
            // ==============================================================
            // Root View with Environment Injection
            // ==============================================================
            // SwiftUI Environment is the recommended way to distribute
            // dependencies throughout the view hierarchy.
            //
            // The same ContentView works with both real and mock providers,
            // demonstrating the power of protocol-based dependency injection.

            Group {
                if isDemoMode {
                    DemoModeContentView()
                } else {
                    ContentView()
                }
            }
            .environment(\.authProvider, authProvider)
            .environment(\.analyticsProvider, analyticsProvider)
            .environment(\.storageProvider, storageProvider)
            .environment(\.crashlyticsProvider, crashlyticsProvider)
        }
    }
}

// MARK: - Demo Mode Content View

/// A wrapper view that shows a banner indicating demo mode.
struct DemoModeContentView: View {
    @State private var showDemoBanner = true

    var body: some View {
        ZStack(alignment: .top) {
            ContentView()

            if showDemoBanner {
                demoBanner
            }
        }
    }

    private var demoBanner: some View {
        HStack {
            Image(systemName: "info.circle.fill")
            Text("Demo Mode")
                .fontWeight(.medium)
            Text("– No Firebase configured")
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                withAnimation {
                    showDemoBanner = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.top, 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
