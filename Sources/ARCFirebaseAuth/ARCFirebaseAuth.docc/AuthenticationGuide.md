# Authentication Guide

Learn how to implement user authentication in your app.

## Overview

This guide covers the complete authentication workflow, from user sign-up to session management.

## Basic Setup

```swift
import ARCFirebaseAuth

// Configure at app launch
FirebaseManager.configure()
try AuthManager.shared.configure()
```

## User Sign Up

Create new user accounts with email and password:

```swift
do {
    let user = try await AuthManager.shared.signUp(
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
do {
    let user = try await AuthManager.shared.signIn(
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
if AuthManager.shared.isAuthenticated {
    if let user = AuthManager.shared.currentUser {
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
do {
    try AuthManager.shared.signOut()
    print("User signed out")
} catch {
    print("Sign out failed: \(error)")
}
```

## SwiftUI Integration

### View Modifier for Auth State

```swift
struct ContentView: View {
    @State private var isAuthenticated = AuthManager.shared.isAuthenticated

    var body: some View {
        if isAuthenticated {
            HomeView()
        } else {
            SignInView()
        }
    }
}
```

### Sign In Form

```swift
struct SignInView: View {
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
                _ = try await AuthManager.shared.signIn(
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
do {
    let user = try await AuthManager.shared.signIn(
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
guard let user = AuthManager.shared.currentUser else { return }

if !user.isEmailVerified {
    // Prompt user to verify email
    showEmailVerificationAlert()
}
```

### Automatic Sign In After Sign Up

```swift
// After successful sign up, user is automatically signed in
let user = try await AuthManager.shared.signUp(
    email: email,
    password: password
)

// User is now authenticated
assert(AuthManager.shared.isAuthenticated)
```

## Security Tips

1. **Never store passwords**: Let Firebase handle password storage
2. **Use HTTPS**: Firebase enforces HTTPS automatically
3. **Validate on server**: Don't trust client-side validation alone
4. **Implement rate limiting**: Prevent brute force attacks
5. **Monitor auth events**: Use Analytics to track sign-ins

## See Also

- ``AuthManager``
- ``User``
- <doc:/ARCFirebaseCore/SecurityBestPractices>
