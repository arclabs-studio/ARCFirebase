import ARCFirebaseAnalytics
import ARCFirebaseAuth
import SwiftUI

struct ContentView: View {
    @Environment(\.authProvider) private var auth
    @Environment(\.analyticsProvider) private var analytics
    @State private var authViewModel: AuthViewModel?

    var body: some View {
        Group {
            if let viewModel = authViewModel {
                if viewModel.isAuthenticated {
                    MainTabView()
                        .environment(viewModel)
                } else {
                    SignInView()
                        .environment(viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .task {
            if authViewModel == nil {
                authViewModel = AuthViewModel(auth: auth, analytics: analytics)
            }
        }
    }
}

struct MainTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        TabView {
            ItemsListView()
                .tabItem {
                    Label("Items", systemImage: "list.bullet")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("User Info") {
                    if let user = authViewModel.currentUser {
                        LabeledContent("Email", value: user.email ?? "N/A")
                        LabeledContent("User ID", value: user.id)
                        LabeledContent("Verified", value: user.isEmailVerified ? "Yes" : "No")
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
}
