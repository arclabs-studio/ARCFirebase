//
//  ContentView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import ARCFirebaseAuth
import SwiftUI

// MARK: - ContentView

/// Root view that handles authentication state and navigation.
///
/// This view demonstrates the **authentication flow pattern**:
///
/// 1. **Loading State**: Shows a spinner while checking auth status
/// 2. **Unauthenticated**: Shows SignInView for user to log in
/// 3. **Authenticated**: Shows MainTabView with app content
///
/// ## Architecture Pattern
///
/// The view creates an `AuthViewModel` lazily and passes it to child views
/// via SwiftUI's `@Environment`. This pattern:
/// - Centralizes auth state management
/// - Enables easy testing with mock providers
/// - Follows the Single Source of Truth principle
struct ContentView: View {
    // MARK: Private Properties

    /// Access to authentication provider from environment.
    @Environment(\.authProvider) private var auth

    /// Access to analytics provider from environment.
    @Environment(\.analyticsProvider) private var analytics

    /// The authentication view model, created lazily.
    @State private var authViewModel: AuthViewModel?

    // MARK: View

    var body: some View {
        Group {
            if let viewModel = authViewModel {
                // ================================================================
                // Authentication State Routing
                // ================================================================
                // Based on auth state, show either login screen or main app.
                // This pattern ensures users always see the appropriate UI.

                if viewModel.isAuthenticated {
                    MainTabView()
                        .environment(viewModel)
                } else {
                    SignInView()
                        .environment(viewModel)
                }
            } else {
                // ================================================================
                // Loading State
                // ================================================================
                // While ViewModel initializes and checks auth status,
                // show a loading indicator to prevent UI flashing.

                ProgressView("Loading...")
                    .progressViewStyle(.circular)
            }
        }
        .task {
            // ================================================================
            // Lazy ViewModel Initialization
            // ================================================================
            // Create ViewModel only once when view appears.
            // This ensures providers from environment are available.

            if authViewModel == nil {
                authViewModel = AuthViewModel(auth: auth, analytics: analytics)
            }
        }
    }
}

// MARK: - MainTabView

/// Main app container with tab-based navigation.
///
/// This view demonstrates:
/// - Tab bar navigation pattern
/// - Environment propagation to tab content
/// - Screen view analytics tracking
struct MainTabView: View {
    // MARK: Private Properties

    /// Access to shared auth state from parent.
    @Environment(AuthViewModel.self) private var authViewModel

    /// Access to analytics for screen tracking.
    @Environment(\.analyticsProvider) private var analytics

    /// Currently selected tab index.
    @State private var selectedTab = 0

    // MARK: View

    var body: some View {
        TabView(selection: $selectedTab) {
            // ==============================================================
            // Items Tab - Firestore Demo
            // ==============================================================
            // Demonstrates CRUD operations with FirestoreRepository.

            ItemsListView()
                .tabItem {
                    Label("Items", systemImage: "list.bullet")
                }
                .tag(0)

            // ==============================================================
            // Storage Tab - Cloud Storage Demo
            // ==============================================================
            // Demonstrates file upload/download with StorageProvider.

            StorageDemoView()
                .tabItem {
                    Label("Storage", systemImage: "photo.on.rectangle")
                }
                .tag(1)

            // ==============================================================
            // Profile Tab - User Info & Sign Out
            // ==============================================================
            // Shows current user info and sign out functionality.

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
        .onChange(of: selectedTab) { _, newTab in
            // Track tab changes for analytics
            let tabNames = ["items", "storage", "profile"]
            analytics.logScreenView(tabNames[newTab])
        }
    }
}

// MARK: - ProfileView

/// User profile view with account information and sign out.
///
/// This view demonstrates:
/// - Reading user data from AuthViewModel
/// - Sign out functionality
/// - Crashlytics context setting
struct ProfileView: View {
    // MARK: Private Properties

    @Environment(AuthViewModel.self) private var authViewModel

    // MARK: View

    var body: some View {
        NavigationStack {
            List {
                // ==============================================================
                // User Information Section
                // ==============================================================
                Section("User Information") {
                    if let user = authViewModel.currentUser {
                        LabeledContent("Email", value: user.email ?? "N/A")
                        LabeledContent("User ID", value: String(user.id.prefix(8)) + "...")
                        LabeledContent("Verified", value: user.isEmailVerified ? "Yes" : "No")

                        if let createdAt = user.creationDate {
                            LabeledContent("Member Since") {
                                Text(createdAt, style: .date)
                            }
                        }
                    } else {
                        Text("No user data available")
                            .foregroundStyle(.secondary)
                    }
                }

                // ==============================================================
                // Actions Section
                // ==============================================================
                Section {
                    Button("Sign Out", role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                }

                // ==============================================================
                // Debug Section (Development Only)
                // ==============================================================
                #if DEBUG
                Section("Debug") {
                    Button("Test Crashlytics Log") {
                        authViewModel.testCrashlyticsLog()
                    }

                    Button("Test Non-Fatal Error") {
                        authViewModel.testNonFatalError()
                    }
                }
                #endif
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Previews

#Preview("Content View - Loading") {
    ContentView()
        .previewEnvironment()
}

#Preview("Main Tab View") {
    let mockAuth = MockAuthProvider.authenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.mockAuthenticate()

    return MainTabView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Profile View - Light") {
    let mockAuth = MockAuthProvider.authenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.mockAuthenticate()

    return NavigationStack {
        ProfileView()
    }
    .environment(viewModel)
    .previewEnvironment()
}

#Preview("Profile View - Dark") {
    let mockAuth = MockAuthProvider.authenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.mockAuthenticate()

    return NavigationStack {
        ProfileView()
    }
    .environment(viewModel)
    .previewEnvironment()
    .preferredColorScheme(.dark)
}
