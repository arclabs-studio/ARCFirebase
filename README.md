# ARCFirebase

Modular Firebase integration for ARC Labs Studio apps.

> Part of the ARC Labs Studio package ecosystem

## Features

- **Modular architecture**: Import only what you need
- **Type-safe APIs**: Protocol-based, Swift-first design
- **Async/await**: Modern concurrency throughout
- **Comprehensive logging**: ARCLogger integration
- **Full DocC documentation**: Learn as you code
- **Multi-app ready**: Reusable across all ARC Labs apps
- **Production tested**: Used in FavRes, FavBook, and more

## Example App

A complete SwiftUI example app is available in [`Examples/ARCFirebaseExample`](Examples/ARCFirebaseExample/README.md) demonstrating:

- Authentication (sign up, sign in, sign out)
- Firestore CRUD operations with generic repository
- Analytics event tracking
- Crashlytics error reporting
- Complete SwiftUI architecture with MVVM

Perfect for learning how to integrate ARCFirebase in your app!

## Modules

| Module | Description | Firebase SDK |
|--------|-------------|--------------|
| **Core** | Configuration & utilities | FirebaseCore |
| **Auth** | User authentication | FirebaseAuth |
| **Analytics** | Event tracking | FirebaseAnalytics |
| **Crashlytics** | Crash reporting | FirebaseCrashlytics |
| **Persistence** | Firestore database | FirebaseFirestore |
| **Storage** | File storage | FirebaseStorage |

## Installation

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

## Setup

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

@main
struct FavResApp: App {
    init() {
        // Configure Firebase
        FirebaseManager.configure()

        // Configure services
        try? AuthManager.shared.configure()
        try? AnalyticsManager.shared.configure()
        try? CrashlyticsManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Usage Examples

### Authentication

```swift
import ARCFirebaseAuth

// Sign up
let user = try await AuthManager.shared.signUp(
    email: "user@example.com",
    password: "securePassword"
)

// Sign in
let user = try await AuthManager.shared.signIn(
    email: "user@example.com",
    password: "password"
)

// Check status
if AuthManager.shared.isAuthenticated {
    print("Signed in as: \(AuthManager.shared.currentUser?.email)")
}

// Sign out
try AuthManager.shared.signOut()
```

### Analytics

```swift
import ARCFirebaseAnalytics

// Track events
AnalyticsManager.shared.logEvent("restaurant_viewed", parameters: [
    "restaurant_id": "abc123",
    "category": "italian"
])

// Screen tracking
AnalyticsManager.shared.logScreenView("RestaurantDetail")

// User properties
AnalyticsManager.shared.setUserProperty("premium", value: "true")
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

```swift
import ARCFirebaseStorage

// Upload
let imageData = image.jpegData(compressionQuality: 0.8)!
let url = try await StorageManager.shared.upload(
    data: imageData,
    path: "restaurants/\(id)/photo.jpg",
    contentType: "image/jpeg"
)

// Download URL
let url = try await StorageManager.shared.downloadURL(
    path: "restaurants/\(id)/photo.jpg"
)

// Delete
try await StorageManager.shared.delete(
    path: "restaurants/\(id)/photo.jpg"
)
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

## Documentation

Full DocC documentation included. Build with:

```bash
swift package generate-documentation
```

Or explore online at [docs.arclabs.studio/arcfirebase](https://docs.arclabs.studio/arcfirebase)

## Testing

```bash
swift test
```

## Security

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

## Multi-App Support

ARCFirebase works across multiple apps. Each app uses its own Firebase project:

```
FavRes     → Firebase Project "FavRes"
FavBook    → Firebase Project "FavBook"
SpatialShoes → Firebase Project "Spatial Shoes"
```

Same package, different configs. See [Multi-App Setup Guide](Sources/ARCFirebaseCore/ARCFirebaseCore.docc/MultiAppSetup.md).

## Platform Support

- iOS 17+
- macOS 14+
- watchOS 10+
- visionOS 1+

## License

MIT License - ARC Labs Studio

## Related Packages

- [ARCLogger](https://github.com/arclabs/ARCLogger) - Logging system
- [ARCMetrics](https://github.com/arclabs/ARCMetrics) - MetricKit integration
- [ARCNetworking](https://github.com/arclabs/ARCNetworking) - API client (coming soon)

---

**Built with ❤️ by ARC Labs Studio**
