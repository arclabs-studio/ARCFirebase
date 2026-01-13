import SwiftUI

/// SwiftUI Environment key for auth provider.
///
/// This allows passing the auth provider through the SwiftUI environment:
///
/// ```swift
/// @main
/// struct FavResApp: App {
///     let auth = FirebaseAuthProvider.live
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.authProvider, auth)
///         }
///     }
/// }
///
/// struct MyView: View {
///     @Environment(\.authProvider) var auth
///
///     var body: some View {
///         Button("Sign In") {
///             Task {
///                 try await auth.signIn(email: email, password: password)
///             }
///         }
///     }
/// }
/// ```
public struct AuthProviderKey: EnvironmentKey {
    public static let defaultValue: any AuthProviding = FirebaseAuthProvider.live
}

extension EnvironmentValues {

    /// The authentication provider in the environment.
    public var authProvider: any AuthProviding {
        get { self[AuthProviderKey.self] }
        set { self[AuthProviderKey.self] = newValue }
    }
}
