# ``ARCFirebaseAuth``

Firebase Authentication integration for ARC Labs Studio apps.

## Overview

ARCFirebaseAuth provides a simplified interface to Firebase Authentication with support for email/password authentication, user management, and authentication state.

The module follows a protocol-based architecture for testability and flexibility, allowing you to easily swap implementations or use mocks in tests.

## Key Features

- **Protocol-based design**: Use `AuthProviding` for dependency injection
- **Email/Password authentication**: Built-in sign up and sign in
- **User management**: Track current user state
- **Type-safe**: Swift-first API with async/await
- **Actor-based**: Thread-safe with Swift concurrency
- **SwiftUI integration**: Environment values support
- **Logging**: ARCLogger integration for debugging

## Topics

### Getting Started

- <doc:AuthenticationGuide>

### Protocols

- ``AuthProviding``

### Implementations

- ``FirebaseAuthProvider``
- ``FirebaseAuthProvider/signIn(email:password:)``
- ``FirebaseAuthProvider/signUp(email:password:)``
- ``FirebaseAuthProvider/signOut()``

### SwiftUI Integration

- ``AuthProviderKey``

### User Management

- ``User``
- ``AuthProviding/currentUser``
- ``AuthProviding/isAuthenticated``
