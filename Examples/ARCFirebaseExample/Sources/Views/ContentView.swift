import SwiftUI
import ARCFirebaseAuth

struct ContentView: View {

    @State private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environment(authViewModel)
            } else {
                SignInView()
                    .environment(authViewModel)
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
                        authViewModel.signOut()
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
