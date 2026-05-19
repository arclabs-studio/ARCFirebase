# 🔥 ARCFirebase

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20%7C%20macOS%2014%20%7C%20watchOS%2010%20%7C%20visionOS%201-blue.svg)
![License](https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**Modular Firebase integration for ARC Labs Studio apps**

Protocol-based design • Actor-safe concurrency • SwiftUI Environment • Full testability

---

## 🎯 Overview

ARCFirebase provides a clean, modular architecture for integrating Firebase services into Swift applications. Each Firebase service is wrapped in a protocol-based abstraction that enables dependency injection and comprehensive testing.

> Part of the ARC Labs Studio package ecosystem

### Key Features

- **Modular architecture**: Import only what you need
- **Protocol-based design**: Dependency injection for testability
- **Type-safe APIs**: Swift-first, async/await throughout
- **Actor-based**: Thread-safe with Swift concurrency
- **SwiftUI integration**: Environment values support
- **Comprehensive logging**: ARCLogger integration
- **Full DocC documentation**: Learn as you code
- **Multi-app ready**: Reusable across multiple apps and Firebase projects
- **Production tested**: Used across ARC Labs Studio apps

---

## 📋 Requirements

- **Swift:** 6.0+
- **Platforms:** iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / visionOS 1.0+
- **Xcode:** 16.0+
- **Dependencies:** Firebase iOS SDK 11.13.0+, ARCLogger

---

## Example App

A complete SwiftUI example app is available in [`Examples/ARCFirebaseExample`](Examples/ARCFirebaseExample/README.md) demonstrating:

- Authentication (sign up, sign in, sign out)
- Firestore CRUD operations with generic repository
- Analytics event tracking
- Crashlytics error reporting
- Complete SwiftUI architecture with MVVM

Perfect for learning how to integrate ARCFirebase in your app!

---

## 📦 Modules

| Module | Description | Firebase SDK |
|--------|-------------|--------------|
| **Core** | Configuration & utilities | FirebaseCore |
| **Auth** | User authentication | FirebaseAuth |
| **Analytics** | Event tracking | FirebaseAnalytics |
| **Crashlytics** | Crash reporting | FirebaseCrashlytics |
| **Persistence** | Firestore database | FirebaseFirestore |
| **Storage** | File storage | FirebaseStorage |
| **AI** | Gemini content generation | FirebaseAI |

---

## 🚀 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arclabs/ARCFirebase.git", from: "1.0.0")
]
```

### Import Modules

```swift
// Import all modules
import ARCFirebase

// Or import selectively
import ARCFirebaseCore
import ARCFirebaseAuth
import ARCFirebaseAnalytics
```

---

## ⚙️ Setup

### 1. Download GoogleService-Info.plist

1. Create Firebase project in [Firebase Console](https://console.firebase.google.com)
2. Register your iOS app
3. Download `GoogleService-Info.plist`
4. Add to your Xcode project (**NOT** to the package)

### 2. Configure Firebase

```swift
import SwiftUI
import ARCFirebaseCore
import ARCFirebaseAuth
import ARCFirebaseAnalytics
import ARCFirebaseStorage
import ARCFirebaseCrashlytics
import ARCFirebaseAI

@main
struct MyApp: App {
    // Initialize providers
    private let auth: FirebaseAuthProvider
    private let analytics: FirebaseAnalyticsProvider
    private let storage: FirebaseStorageProvider
    private let ai: FirebaseAIProvider

    init() {
        // Configure Firebase Core
        FirebaseManager.configure()

        // Initialize providers
        do {
            auth = try FirebaseAuthProvider()
            analytics = FirebaseAnalyticsProvider()
            storage = try FirebaseStorageProvider()
            ai = try FirebaseAIProvider()
            try CrashlyticsManager.shared.configure()
        } catch {
            fatalError("Firebase configuration failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authProvider, auth)
                .environment(\.analyticsProvider, analytics)
                .environment(\.storageProvider, storage)
                .environment(\.aiProvider, ai)
        }
    }
}
```

---

## 📖 Usage Examples

### Authentication

#### SwiftUI with Environment

```swift
import SwiftUI
import ARCFirebaseAuth

struct MyView: View {
    @Environment(\.authProvider) var auth

    var body: some View {
        Button("Sign In") {
            Task {
                let user = try await auth.signIn(
                    email: "user@example.com",
                    password: "password"
                )
                print("Signed in: \(user.email ?? "")")
            }
        }
    }
}
```

#### Dependency Injection

```swift
import ARCFirebaseAuth

class AuthViewModel {
    private let auth: any AuthProviding

    init(auth: any AuthProviding) {
        self.auth = auth
    }

    func signUp(email: String, password: String) async throws {
        let user = try await auth.signUp(email: email, password: password)
        print("User created: \(user.id)")
    }

    func signIn(email: String, password: String) async throws {
        let user = try await auth.signIn(email: email, password: password)
        let isAuthenticated = await auth.isAuthenticated
        print("Authenticated: \(isAuthenticated)")
    }

    func signOut() async throws {
        try await auth.signOut()
    }
}

// Production
let viewModel = AuthViewModel(auth: FirebaseAuthProvider.live)

// Testing
let viewModel = AuthViewModel(auth: MockAuthProvider())
```

### Analytics

#### SwiftUI with Environment

```swift
import SwiftUI
import ARCFirebaseAnalytics

struct RestaurantView: View {
    @Environment(\.analyticsProvider) var analytics

    var body: some View {
        VStack {
            // Your UI
        }
        .onAppear {
            analytics.logScreenView("RestaurantDetail")
            analytics.logEvent("restaurant_viewed", parameters: [
                "restaurant_id": "abc123",
                "category": "italian"
            ])
        }
    }
}
```

#### Dependency Injection

```swift
import ARCFirebaseAnalytics

class ItemViewModel {
    private let analytics: any AnalyticsProviding

    init(analytics: any AnalyticsProviding) {
        self.analytics = analytics
    }

    func trackAction() {
        analytics.logEvent("user_action", parameters: ["key": "value"])
        analytics.setUserProperty("premium", value: "true")
    }
}

// Production
let viewModel = ItemViewModel(analytics: FirebaseAnalyticsProvider.live)

// Testing
let viewModel = ItemViewModel(analytics: MockAnalyticsProvider())
```

### Firestore (Persistence)

```swift
import ARCFirebasePersistence

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
}

// Create repository
let repository = try FirestoreRepository<Restaurant>(
    collectionPath: "restaurants"
)

// CRUD operations
try await repository.save(restaurant)
let restaurant = try await repository.fetch(id: "abc123")
let all = try await repository.fetchAll()
try await repository.update(restaurant)
try await repository.delete(id: "abc123")

// Queries
let italian = try await repository.query(
    where: "category",
    isEqualTo: "italian"
)

let top = try await repository.query(
    orderBy: "rating",
    descending: true,
    limit: 10
)
```

### Storage

#### SwiftUI with Environment

```swift
import SwiftUI
import ARCFirebaseStorage

struct ImageUploadView: View {
    @Environment(\.storageProvider) var storage
    @State private var uploadedURL: URL?

    func uploadImage(_ imageData: Data) async throws {
        uploadedURL = try await storage.upload(
            data: imageData,
            path: "photos/\(UUID().uuidString).jpg",
            contentType: "image/jpeg"
        )
    }
}
```

#### Dependency Injection

```swift
import ARCFirebaseStorage

class ImageUploader {
    private let storage: any StorageProviding

    init(storage: any StorageProviding) {
        self.storage = storage
    }

    func upload(_ imageData: Data, path: String) async throws -> URL {
        return try await storage.upload(
            data: imageData,
            path: path,
            contentType: "image/jpeg"
        )
    }

    func delete(path: String) async throws {
        try await storage.delete(path: path)
    }
}

// Production
let uploader = ImageUploader(storage: FirebaseStorageProvider.live)

// Testing
let uploader = ImageUploader(storage: MockStorageProvider())
```

### Crashlytics

```swift
import ARCFirebaseCrashlytics

// Record errors
do {
    try riskyOperation()
} catch {
    CrashlyticsManager.shared.record(error: error)
}

// Custom logs
CrashlyticsManager.shared.log("User action: \(action)")

// User context
CrashlyticsManager.shared.setUserID(user.id)
CrashlyticsManager.shared.setCustomValue("dark", forKey: "theme")
```

### AI (Gemini via Firebase)

#### SwiftUI with Environment

```swift
import SwiftUI
import ARCFirebaseAI

struct ChatView: View {
    @Environment(\.aiProvider) var ai
    @State private var response = ""

    var body: some View {
        VStack {
            Text(response)
            Button("Generate") {
                Task {
                    let result = try await ai.generateContent(
                        prompt: "Suggest a restaurant"
                    )
                    response = result.content
                }
            }
        }
    }
}
```

#### Streaming

```swift
for try await chunk in ai.streamContent(prompt: "Tell me about sushi") {
    text += chunk
}
```

#### Dependency Injection

```swift
import ARCFirebaseAI

@Observable
final class ChatViewModel {
    private let ai: any AIProviding
    var response: String = ""

    init(ai: any AIProviding) {
        self.ai = ai
    }

    func generate(prompt: String) async throws {
        let result = try await ai.generateContent(prompt: prompt)
        response = result.content
    }
}

// Production
let viewModel = ChatViewModel(ai: FirebaseAIProvider.live)

// Testing
let viewModel = ChatViewModel(ai: MockAIProvider())
```

---

## 🔄 Migration Guide

Migrating from singleton pattern to protocol-based dependency injection.

### From Singleton to DI Pattern

**Before (Singleton):**

```swift
// Old: Direct singleton access
AuthManager.shared.signIn(email: email, password: password)
AnalyticsManager.shared.logEvent("user_action")
StorageManager.shared.upload(data: data, path: path, contentType: type)
```

**After (Dependency Injection):**

```swift
// New: Inject dependencies
class MyViewModel {
    private let auth: any AuthProviding
    private let analytics: any AnalyticsProviding
    private let storage: any StorageProviding

    init(auth: any AuthProviding, analytics: any AnalyticsProviding, storage: any StorageProviding) {
        self.auth = auth
        self.analytics = analytics
        self.storage = storage
    }

    func signIn() async throws {
        try await auth.signIn(email: email, password: password)
        analytics.logEvent("user_signed_in")
    }
}
```

### SwiftUI Environment Setup

**Before:**

```swift
@main
struct MyApp: App {
    init() {
        FirebaseManager.configure()
        try? AuthManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**After:**

```swift
@main
struct MyApp: App {
    private let auth = FirebaseAuthProvider.live
    private let analytics = FirebaseAnalyticsProvider.live
    private let storage = FirebaseStorageProvider.live

    init() {
        FirebaseManager.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.authProvider, auth)
                .environment(\.analyticsProvider, analytics)
                .environment(\.storageProvider, storage)
        }
    }
}
```

### Testing Benefits

**Before (Hard to test):**

```swift
// Cannot mock AuthManager.shared
func testSignIn() async {
    // This hits real Firebase!
    try await AuthManager.shared.signIn(email: "test@test.com", password: "password")
}
```

**After (Easy to test):**

```swift
// Mock implementation
actor MockAuthProvider: AuthProviding {
    var mockUser: User?

    var currentUser: User? {
        get async { mockUser }
    }

    func signIn(email: String, password: String) async throws -> User {
        let user = User(id: "mock-id", email: email)
        mockUser = user
        return user
    }
    // ... other methods
}

// Test with mock
func testSignIn() async throws {
    let mock = MockAuthProvider()
    let viewModel = AuthViewModel(auth: mock)

    try await viewModel.signIn(email: "test@test.com", password: "password")

    let user = await mock.currentUser
    #expect(user?.email == "test@test.com")
}
```

### Key Changes

| Component | Old Name | New Name | Type |
|-----------|----------|----------|------|
| Auth | `AuthManager.shared` | `FirebaseAuthProvider` | Actor |
| Analytics | `AnalyticsManager.shared` | `FirebaseAnalyticsProvider` | Class (@unchecked Sendable) |
| Storage | `StorageManager.shared` | `FirebaseStorageProvider` | Actor |

### Actor Isolation

Auth and Storage providers are now actors for thread safety:

```swift
// Async access required for actor properties
let isAuthenticated = await auth.isAuthenticated
let user = await auth.currentUser

// Methods are already async, no change needed
try await auth.signIn(email: email, password: password)
```

### What Stays the Same

- **FirebaseManager**: Still a singleton (stateless coordinator)
- **CrashlyticsManager**: Still a singleton (global logging)
- **FirestoreRepository**: Already protocol-based, no changes needed

---

## 📚 Documentation

Full DocC documentation included. Build with:

```bash
swift package generate-documentation
```

Or explore online at [docs.arclabs.studio/arcfirebase](https://docs.arclabs.studio/arcfirebase)

---

## 🧪 Testing

```bash
swift test
```

---

## 🔐 Security

### Production Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                        && request.auth.uid == userId;
    }

    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Don't Commit Secrets

Add to `.gitignore`:

```gitignore
GoogleService-Info.plist
```

---

## 🏢 Multi-App Support

ARCFirebase works across multiple apps. Each app uses its own Firebase project:

```
AppA → Firebase Project "AppA"
AppB → Firebase Project "AppB"
AppC → Firebase Project "AppC"
```

Same package, different configs. See [Multi-App Setup Guide](Sources/ARCFirebaseCore/ARCFirebaseCore.docc/MultiAppSetup.md).

---

## 📱 Platform Support

- iOS 17+
- macOS 14+
- watchOS 10+
- visionOS 1+

---

## 🏗️ Architecture

ARCFirebase follows the **Protocol + Provider + EnvironmentKey** pattern across all modules:

```
Protocol          → defines the contract, enables dependency injection
Provider          → production implementation backed by Firebase SDK
EnvironmentKey    → SwiftUI Environment integration
Mock (in Tests)   → test double for unit testing
```

### Module Dependency Graph

```
ARCFirebaseCore (required by all)
    ├── ARCFirebaseAuth         (actor — thread-safe)
    ├── ARCFirebaseAnalytics    (@unchecked Sendable)
    ├── ARCFirebaseCrashlytics  (singleton — global logging)
    ├── ARCFirebasePersistence  (generic Firestore repository)
    ├── ARCFirebaseStorage      (actor — thread-safe)
    ├── ARCFirebaseAI           (actor — Gemini via Firebase AI)
    └── ARCFirebaseFeatureFlags (Remote Config)
```

Import only the modules your app needs — there is no required umbrella import.

---

## 🤝 Contributing

This package is maintained by ARC Labs Studio. To contribute:

1. Follow the [ARC Labs branch naming conventions](https://github.com/arclabs-studio/ARCKnowledge): `feature/`, `bugfix/`, or `hotfix/` — include the Linear issue ID (e.g. `feature/ARC-42-add-messaging`)
2. Run the full test suite before opening a PR: `swift test`
3. Ensure SwiftLint and SwiftFormat pass: `make lint && make format`
4. Add tests for any new public API — mock providers live in `Tests/*/Mocks/`
5. Update `CHANGELOG.md` under `[Unreleased]`

---

## 📄 License

Source-available under **PolyForm Noncommercial License 1.0.0** © 2025–2026 ARC Labs Studio. Free for non-commercial use (research, study, hobby, evaluation).

ARC Labs Studio holds an internal commercial grant covering its own products — see [INTERNAL-USE.md](INTERNAL-USE.md). External commercial users must contact `arclabs.studio@gmail.com` for a separate license.

See [LICENSE](LICENSE) for the full license text.

---

## 🔗 Related Packages

- [ARCLogger](https://github.com/arclabs/ARCLogger) - Logging system
- [ARCMetrics](https://github.com/arclabs/ARCMetrics) - MetricKit integration
- [ARCNetworking](https://github.com/arclabs/ARCNetworking) - API client (coming soon)
- [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge) - Development standards
- [ARCDevTools](https://github.com/arclabs-studio/ARCDevTools) - Quality tooling

---

<div align="center">

Made with 💛 by ARC Labs Studio

[**GitHub**](https://github.com/arclabs-studio) • [**Issues**](https://github.com/arclabs-studio/ARCFirebase/issues)

</div>
