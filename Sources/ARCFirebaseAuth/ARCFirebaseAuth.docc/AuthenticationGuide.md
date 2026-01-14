# Authentication Guide

Learn how to implement user authentication in your app.

## Overview

This guide covers the complete authentication workflow, from user sign-up to session management, using the protocol-based architecture for dependency injection and testability.

## Basic Setup

### Production Setup

```swift
import ARCFirebaseAuth
import ARCFirebaseCore

// Configure Firebase at app launch
FirebaseManager.configure()

// Create the auth provider
let auth = try FirebaseAuthProvider()
// Or use the convenience accessor
let auth = FirebaseAuthProvider.live
```

### Dependency Injection

For better testability, inject the auth provider into your classes:

```swift
class AuthViewModel {
    private let auth: any AuthProviding

    init(auth: any AuthProviding) {
        self.auth = auth
    }

    func signIn(email: String, password: String) async throws {
        let user = try await auth.signIn(email: email, password: password)
        // Handle successful sign in
    }
}

// Production
let viewModel = AuthViewModel(auth: FirebaseAuthProvider.live)

// Testing
let viewModel = AuthViewModel(auth: MockAuthProvider())
```

## User Sign Up

Create new user accounts with email and password:

```swift
let auth = FirebaseAuthProvider.live

do {
    let user = try await auth.signUp(
        email: "user@example.com",
        password: "securePassword123"
    )
    print("Account created: \(user.id)")
    print("Email: \(user.email ?? "N/A")")
} catch {
    print("Sign up failed: \(error)")
}
```

## User Sign In

Authenticate existing users:

```swift
let auth = FirebaseAuthProvider.live

do {
    let user = try await auth.signIn(
        email: "user@example.com",
        password: "password123"
    )
    print("Signed in: \(user.displayName ?? user.email ?? "User")")
} catch {
    print("Sign in failed: \(error)")
}
```

## Check Authentication State

Monitor the current user's authentication status:

```swift
let auth = FirebaseAuthProvider.live

if await auth.isAuthenticated {
    if let user = await auth.currentUser {
        print("User ID: \(user.id)")
        print("Email: \(user.email ?? "N/A")")
        print("Verified: \(user.isEmailVerified)")
    }
} else {
    print("No user signed in")
}
```

## Sign Out

Log out the current user:

```swift
let auth = FirebaseAuthProvider.live

do {
    try await auth.signOut()
    print("User signed out")
} catch {
    print("Sign out failed: \(error)")
}
```

## SwiftUI Integration

### Environment Values

Use SwiftUI's environment to pass the auth provider through your view hierarchy:

```swift
import SwiftUI
import ARCFirebaseAuth

@main
struct MyApp: App {
    let auth = FirebaseAuthProvider.live

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authProvider, auth)
        }
    }
}
```

### View with Auth State

Access the auth provider from the environment:

```swift
struct ContentView: View {
    @Environment(\.authProvider) var auth
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                HomeView()
            } else {
                SignInView()
            }
        }
        .task {
            isAuthenticated = await auth.isAuthenticated
        }
    }
}
```

### Sign In Form

```swift
struct SignInView: View {
    @Environment(\.authProvider) var auth
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textContentType(.password)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Sign In") {
                signIn()
            }
            .disabled(isLoading)
        }
    }

    func signIn() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await auth.signIn(
                    email: email,
                    password: password
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
```

## Error Handling

Handle common authentication errors:

```swift
let auth = FirebaseAuthProvider.live

do {
    let user = try await auth.signIn(
        email: email,
        password: password
    )
} catch let error as NSError {
    switch error.code {
    case 17008: // Invalid email
        showError("Invalid email address")
    case 17009: // Wrong password
        showError("Incorrect password")
    case 17011: // User not found
        showError("No account found with this email")
    default:
        showError(error.localizedDescription)
    }
}
```

## Best Practices

### Password Requirements

Enforce strong passwords in your UI:

```swift
func validatePassword(_ password: String) -> Bool {
    // Firebase minimum: 6 characters
    // Recommended: 8+ characters with mixed case, numbers, special chars
    let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    return predicate.evaluate(with: password)
}
```

### Email Verification

Check if user's email is verified:

```swift
let auth = FirebaseAuthProvider.live

guard let user = await auth.currentUser else { return }

if !user.isEmailVerified {
    // Prompt user to verify email
    showEmailVerificationAlert()
}
```

### Automatic Sign In After Sign Up

```swift
let auth = FirebaseAuthProvider.live

// After successful sign up, user is automatically signed in
let user = try await auth.signUp(
    email: email,
    password: password
)

// User is now authenticated
let isAuthenticated = await auth.isAuthenticated
assert(isAuthenticated)
```

### Testing with Mocks

Create a mock provider for testing:

```swift
actor MockAuthProvider: AuthProviding {
    var mockUser: User?
    var mockError: Error?

    var currentUser: User? {
        get async { mockUser }
    }

    var isAuthenticated: Bool {
        get async { mockUser != nil }
    }

    func signIn(email: String, password: String) async throws -> User {
        if let error = mockError {
            throw error
        }
        let user = User(id: "mock-id", email: email)
        mockUser = user
        return user
    }

    // Implement other methods...
}

// In tests
func testSignIn() async throws {
    let mock = MockAuthProvider()
    let viewModel = AuthViewModel(auth: mock)

    try await viewModel.signIn(email: "test@example.com", password: "password")

    let user = await mock.currentUser
    #expect(user?.email == "test@example.com")
}
```

## Security Tips

1. **Never store passwords**: Let Firebase handle password storage
2. **Use HTTPS**: Firebase enforces HTTPS automatically
3. **Validate on server**: Don't trust client-side validation alone
4. **Implement rate limiting**: Prevent brute force attacks
5. **Monitor auth events**: Use Analytics to track sign-ins

## See Also

- ``AuthProviding``
- ``FirebaseAuthProvider``
- ``User``
- <doc:/ARCFirebaseCore/SecurityBestPractices>
