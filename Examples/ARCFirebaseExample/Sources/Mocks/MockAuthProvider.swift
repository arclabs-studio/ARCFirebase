//
//  MockAuthProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAuth
import Foundation
import os

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
final class MockAuthProvider: AuthProviding {
    private struct State {
        var mockUser: User?
        var signInError: Error?
        var signUpError: Error?
        var simulatedDelay: TimeInterval = 0.5
        var signInCallCount: Int = 0
        var signUpCallCount: Int = 0
        var signOutCallCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: Mock Configuration

    /// The mock user to return. Set to `nil` for unauthenticated state.
    var mockUser: User? {
        get { state.withLock { $0.mockUser } }
        set { state.withLock { $0.mockUser = newValue } }
    }

    /// Error to throw on sign in. Set to `nil` for success.
    var signInError: Error? {
        get { state.withLock { $0.signInError } }
        set { state.withLock { $0.signInError = newValue } }
    }

    /// Error to throw on sign up. Set to `nil` for success.
    var signUpError: Error? {
        get { state.withLock { $0.signUpError } }
        set { state.withLock { $0.signUpError = newValue } }
    }

    /// Simulated delay in seconds for async operations.
    var simulatedDelay: TimeInterval {
        get { state.withLock { $0.simulatedDelay } }
        set { state.withLock { $0.simulatedDelay = newValue } }
    }

    // MARK: Call Tracking

    /// Number of times `signIn` was called.
    var signInCallCount: Int {
        state.withLock { $0.signInCallCount }
    }

    /// Number of times `signUp` was called.
    var signUpCallCount: Int {
        state.withLock { $0.signUpCallCount }
    }

    /// Number of times `signOut` was called.
    var signOutCallCount: Int {
        state.withLock { $0.signOutCallCount }
    }

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
        state.withLock { $0.signInCallCount += 1 }

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

        state.withLock { $0.mockUser = user }
        return user
    }

    func signUp(email: String, password _: String) async throws -> User {
        state.withLock { $0.signUpCallCount += 1 }

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

        state.withLock { $0.mockUser = user }
        return user
    }

    func signOut() async throws {
        state.withLock { $0.signOutCallCount += 1 }
        state.withLock { $0.mockUser = nil }
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

        state.withLock { $0.mockUser = user }
        return user
    }

    func reauthenticate(with credential: OAuthCredentialData) async throws -> User {
        try await Task.sleep(for: .seconds(simulatedDelay))

        let user = mockUser ?? User(id: UUID().uuidString,
                                    email: "oauth@example.com",
                                    providerID: credential.providerID,
                                    linkedProviderIDs: [credential.providerID])

        state.withLock { $0.mockUser = user }
        return user
    }

    func revokeToken(authorizationCode _: String) async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
    }

    func authStateChanges() -> AsyncStream<User?> {
        AsyncStream { continuation in
            continuation.yield(mockUser)
            continuation.finish()
        }
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
        state.withLock { $0.mockUser = nil }
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
        state.withLock { $0.mockUser = updated }
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
        state.withLock { $0.mockUser = updated }
        return updated
    }

    func linkedProviders() async -> [String] {
        mockUser?.linkedProviderIDs ?? []
    }

    func sendEmailVerification() async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))
    }

    func updateProfile(displayName: String?, photoURL: URL?) async throws {
        try await Task.sleep(for: .seconds(simulatedDelay))

        guard let user = mockUser else {
            throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }

        let updatedUser = User(id: user.id,
                               email: user.email,
                               displayName: displayName ?? user.displayName,
                               photoURL: photoURL ?? user.photoURL,
                               isEmailVerified: user.isEmailVerified,
                               creationDate: user.creationDate,
                               lastSignInDate: user.lastSignInDate,
                               providerID: user.providerID,
                               linkedProviderIDs: user.linkedProviderIDs)
        state.withLock { [updatedUser] in $0.mockUser = updatedUser }
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
