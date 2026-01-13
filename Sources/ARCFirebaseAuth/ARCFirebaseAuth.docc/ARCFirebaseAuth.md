# ``ARCFirebaseAuth``

Firebase Authentication integration for ARC Labs Studio apps.

## Overview

ARCFirebaseAuth provides a simplified interface to Firebase Authentication with support for email/password authentication, user management, and authentication state.

## Key Features

- **Email/Password authentication**: Built-in sign up and sign in
- **User management**: Track current user state
- **Type-safe**: Swift-first API with async/await
- **Logging**: ARCLogger integration for debugging

## Topics

### Getting Started

- <doc:AuthenticationGuide>

### Authentication

- ``AuthManager``
- ``AuthManager/signIn(email:password:)``
- ``AuthManager/signUp(email:password:)``
- ``AuthManager/signOut()``

### User Management

- ``User``
- ``AuthManager/currentUser``
- ``AuthManager/isAuthenticated``
