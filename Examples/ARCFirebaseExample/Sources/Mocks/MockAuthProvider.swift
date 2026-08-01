//
//  MockAuthProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAuth
import Foundation

// MARK: - MockAuthProvider

/// A mock implementation of `AuthProviding` for SwiftUI previews and testing.
///
/// This provider simulates authentication without connecting to Firebase,
/// making it perfect for:
/// - SwiftUI previews
/// - Unit testing
/// - Development without Firebase configuration
///
/// ## Example Usage
///
/// ```swift
/// // Create a mock with a signed-in user
/// let mockAuth = MockAuthProvider()
/// mockAuth.mockUser = User(
///     id: "123",
///     email: "test@example.com",
///     displayName: "Test User",
///     photoURL: nil,
///     isEmailVerified: true,
///     creationDate: Date(),
///     lastSignInDate: Date()
/// )
///
/// // Use in preview
/// #Preview {
///     MyView()
///         .environment(\.authProvider, mockAuth)
/// }
/// ```
final class MockAuthProvider: AuthProviding, @unchecked Sendable {
    // MARK: Mock Configuration

    /// The mock user to return. Set to `nil` for unauthenticated state.
    var mockUser: User?

    /// Error to throw on sign in. Set to `nil` for success.
    var signInError: Error?

    /// Error to throw on sign up. Set to `nil` for success.
    var signUpError: Error?

    /// Simulated delay in seconds for async operations.
    var simulatedDelay: TimeInterval = 0.5

    // MARK: Call Tracking

    /// Number of times `signIn` was called.
    private(set) var signInCallCount = 0

    /// Number of times `signUp` was called.
    private(set) var signUpCallCount = 0

    /// Number of times `signOut` was called.
    private(set) var signOutCallCount = 0

    // MARK: Initialization

    init(mockUser: User? = nil) {
        self.mockUser = mockUser
    }

    // MARK: AuthProviding Implementation

    var currentUser: User? {
        get async { mockUser }
    }

    var isAuthenticated: Bool {
        get async { mockUser != nil }
    }

    func signIn(email: String, password _: String) async throws -> User {
        signInCallCount += 1

        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = signInError {
            throw error
        }

        // Create or return mock user
        let user = mockUser ?? User(id: UUID().uuidString,
                                    email: email,
                                    displayName: nil,
                                    photoURL: nil,
                                    isEmailVerified: false,
                                    creationDate: Date(),
                                    lastSignInDate: Date())

        mockUser = user
        return user
    }

    func signUp(email: String, password _: String) async throws -> User {
        signUpCallCount += 1

        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = signUpError {
            throw error
        }

        // Create new user
        let user = User(id: UUID().uuidString,
                        email: email,
                        displayName: nil,
                        photoURL: nil,
                        isEmailVerified: false,
                        creationDate: Date(),
                        lastSignInDate: Date())

        mockUser = user
        return user
    }

    func signOut() async throws {
        signOutCallCount += 1
        mockUser = nil
    }

    func sendPasswordReset(email _: String) async throws {
        // No-op for mock
        try await Task.sleep(for: .seconds(simulatedDelay))
    }

    func updatePassword(_: String) async throws {
        // No-op for mock
        try await Task.sleep(for: .seconds(simulatedDelay))
    }

    func signIn(with credential: OAuthCredentialData) async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))

        let user = mockUser ?? User(id: UUID().uuidString,
                                    email: "oauth@example.com",
                                    providerID: credential.providerID,
                                    linkedProviderIDs: [credential.providerID])

        mockUser = user
        return user
    }

    func authStateChanges() -> AsyncStream<User?> {
        AsyncStream { continuation in
            continuation.yield(mockUser)
            continuation.finish()
        }
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
        mockUser = nil
    }

    func linkAccount(with credential: OAuthCredentialData) async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))

        guard let user = mockUser else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }

        let updated = User(id: user.id,
                           email: user.email,
                           displayName: user.displayName,
                           photoURL: user.photoURL,
                           isEmailVerified: user.isEmailVerified,
                           creationDate: user.creationDate,
                           lastSignInDate: user.lastSignInDate,
                           providerID: user.providerID,
                           linkedProviderIDs: user.linkedProviderIDs + [credential.providerID])
        mockUser = updated
        return updated
    }

    func unlinkProvider(_ providerID: String) async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))

        guard let user = mockUser else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }

        let updated = User(id: user.id,
                           email: user.email,
                           displayName: user.displayName,
                           photoURL: user.photoURL,
                           isEmailVerified: user.isEmailVerified,
                           creationDate: user.creationDate,
                           lastSignInDate: user.lastSignInDate,
                           providerID: user.providerID,
                           linkedProviderIDs: user.linkedProviderIDs.filter { $0 != providerID })
        mockUser = updated
        return updated
    }

    func linkedProviders() async -> [String] {
        mockUser?.linkedProviderIDs ?? []
    }

    func sendEmailVerification() async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
    }
}

// MARK: - Convenience Initializers

extension MockAuthProvider {
    /// Creates a mock provider with a pre-authenticated user.
    static var authenticated: MockAuthProvider {
        let provider = MockAuthProvider()
        provider.mockUser = .mock
        return provider
    }

    /// Creates a mock provider in unauthenticated state.
    static var unauthenticated: MockAuthProvider {
        MockAuthProvider(mockUser: nil)
    }
}

// MARK: - Mock User Extension

extension User {
    /// A mock user for previews and testing.
    static var mock: User {
        User(id: "mock-user-123",
             email: "demo@example.com",
             displayName: "Demo User",
             photoURL: nil,
             isEmailVerified: true,
             creationDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
             lastSignInDate: Date())
    }
}
