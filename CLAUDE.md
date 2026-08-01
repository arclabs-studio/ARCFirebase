# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run tests for a specific module
swift test --filter ARCFirebaseAuthTests
swift test --filter ARCFirebaseCoreTests
swift test --filter ARCFirebaseAnalyticsTests
swift test --filter ARCFirebaseCrashlyticsTests
swift test --filter ARCFirebasePersistenceTests
swift test --filter ARCFirebaseStorageTests
swift test --filter ARCFirebaseAITests
swift test --filter ARCFirebaseFeatureFlagsTests

# Generate DocC documentation
swift package generate-documentation
```

## Architecture Overview

ARCFirebase is a **modular Swift Package** providing Firebase integration for ARC Labs apps. It wraps Firebase SDK with protocol-based abstractions for testability.

### Module Structure

```
ARCFirebaseCore          ← Required by all modules (FirebaseManager, FirebaseError)
    ↑
    ├── ARCFirebaseAuth         ← AuthProviding protocol + FirebaseAuthProvider actor
    ├── ARCFirebaseAnalytics    ← AnalyticsProviding protocol + FirebaseAnalyticsProvider
    ├── ARCFirebaseCrashlytics  ← CrashlyticsManager singleton
    ├── ARCFirebasePersistence  ← Repository protocol + FirestoreRepository<T>
    ├── ARCFirebaseStorage      ← StorageProviding protocol + FirebaseStorageProvider actor
    ├── ARCFirebaseAI           ← AIProviding protocol + FirebaseAIProvider (Gemini via Firebase AI)
    └── ARCFirebaseFeatureFlags ← FeatureFlagProviding protocol + FirebaseFeatureFlagProvider (Remote Config)
```

### Design Pattern

Each module follows the **Protocol + Provider + EnvironmentKey** pattern:

1. **Protocol** (e.g., `AuthProviding`) - Defines the contract, enables dependency injection
2. **Provider** (e.g., `FirebaseAuthProvider`) - Production implementation using Firebase SDK
3. **EnvironmentKey** (e.g., `AuthProviderKey`) - SwiftUI Environment integration
4. **Mock** (in Tests) - Test implementation for unit testing

Auth and Storage providers are **actors** for thread safety. Analytics is `@unchecked Sendable`.

### Key Files

- `Sources/ARCFirebaseCore/FirebaseManager.swift` - Singleton for Firebase configuration
- `Sources/ARCFirebase*/[Name]Provider.swift` - Protocol definition
- `Sources/ARCFirebase*/Firebase[Name]Provider.swift` - Firebase implementation
- `Tests/ARCFirebase*Tests/Mocks/Mock*.swift` - Mock implementations for testing

## Testing Conventions

Tests use Swift Testing framework (not XCTest):

```swift
@Suite("FirebaseAuthProvider Tests")
struct FirebaseAuthProviderTests {
    @Test("Mock provider can authenticate user")
    func mockAuthenticationFlow() async throws {
        // Use #expect() for assertions
        #expect(value == expected)
    }
}
```

- Test naming: `methodName_condition` (e.g., `signIn_withValidCredentials`)
- Mock providers track call counts for verification
- Tests run against mock implementations, not real Firebase

## Dependencies

- **firebase-ios-sdk** (11.13.0+) - Firebase iOS SDK
- **ARCLogger** (local path: `../ARCLogger`) - ARC Labs logging system

## Swift Version

Swift 6.0 with strict concurrency. All providers are `Sendable`.

---

# General Engineering Guidelines

## Code Organization

- **One type per file**, named after the type
- **File header** format:
  ```swift
  //
  //  FileName.swift
  //  ARCFirebase
  //
  //  Created by ARC Labs Studio on [Date].
  //
  ```
- **MARK sections**: Use `// MARK: -` for major blocks, `// MARK:` for subsections
- Split files exceeding ~300 lines; split functions exceeding ~30 lines

## SwiftUI Views

- Every View must include previews in both dark and light mode
- Use static mock data in previews, no live dependencies

## GitHub Branches

- `feature/...`, `bugfix/...`, or `hotfix/...`
- Include Linear issue ID: `feature/EX-1-description`
