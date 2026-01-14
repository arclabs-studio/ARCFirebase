# Getting Started with ARCFirebase

Learn how to integrate Firebase into your ARC Labs Studio app.

## Overview

This guide walks you through the complete setup process for adding Firebase to your app, from downloading configuration files to initializing services.

## Prerequisites

Before you begin:

1. Firebase project created (e.g., "FavRes")
2. iOS app registered in Firebase Console
3. `GoogleService-Info.plist` downloaded
4. ARCFirebase package added to your project

## Step 1: Add GoogleService-Info.plist

1. **Download** `GoogleService-Info.plist` from Firebase Console
2. **Drag** it into your Xcode project (NOT into the package)
3. **Verify** it's included in your app target:
   - Select the file in Xcode
   - Check "Target Membership" → Your app target is checked

```
FavRes/
├── FavResApp.swift
├── GoogleService-Info.plist  ← Here, NOT in ARCFirebase package
└── Views/
```

### Security: Don't Commit to Git

Add to your `.gitignore`:

```gitignore
# Firebase
GoogleService-Info.plist
```

**Why?** This file contains API keys for your Firebase project.

## Step 2: Import Modules

```swift
import ARCFirebaseCore
import ARCFirebaseAuth
import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics
import ARCFirebasePersistence
import ARCFirebaseStorage
```

## Step 3: Configure Firebase

Initialize Firebase at app launch:

```swift
import SwiftUI
import ARCFirebaseCore
import ARCFirebaseAuth
import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics

@main
struct FavResApp: App {
    init() {
        // 1. Configure Firebase (reads GoogleService-Info.plist)
        FirebaseManager.configure()

        // 2. Configure services
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

## Step 4: Verify Setup

Run your app and check the console for:

```
[Firebase] Firebase configured successfully
[Auth] AuthManager configured successfully
[Analytics] AnalyticsManager configured successfully
[Crashlytics] CrashlyticsManager configured successfully
```

If you see these logs, Firebase is ready!

## Using Firebase Services

### Authentication

```swift
import ARCFirebaseAuth

// Sign up
let user = try await AuthManager.shared.signUp(
    email: "user@example.com",
    password: "securePassword123"
)

// Sign in
let user = try await AuthManager.shared.signIn(
    email: "user@example.com",
    password: "securePassword123"
)

// Check auth status
if AuthManager.shared.isAuthenticated {
    print("User: \(AuthManager.shared.currentUser?.email)")
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
CrashlyticsManager.shared.log("User viewed restaurant: \(id)")

// User context
CrashlyticsManager.shared.setUserID(user.id)
CrashlyticsManager.shared.setCustomValue("dark", forKey: "theme")
```

### Firestore (Persistence)

```swift
import ARCFirebasePersistence

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
}

let repository = try FirestoreRepository<Restaurant>(
    collectionPath: "restaurants"
)

// Save
try await repository.save(restaurant)

// Fetch
let restaurant = try await repository.fetch(id: "abc123")

// Query
let italianRestaurants = try await repository.query(
    where: "category",
    isEqualTo: "italian"
)
```

### Storage

```swift
import ARCFirebaseStorage

// Upload image
let imageData = image.jpegData(compressionQuality: 0.8)!
let downloadURL = try await StorageManager.shared.upload(
    data: imageData,
    path: "restaurants/\(id)/photo.jpg",
    contentType: "image/jpeg"
)

// Get download URL
let url = try await StorageManager.shared.downloadURL(
    path: "restaurants/\(id)/photo.jpg"
)

// Delete file
try await StorageManager.shared.delete(
    path: "restaurants/\(id)/photo.jpg"
)
```

## Troubleshooting

### "Firebase not configured" Error

**Problem**: You see `FirebaseError.notConfigured`.

**Solution**: Ensure you called `FirebaseManager.configure()` before using any Firebase service.

```swift
// Correct order
FirebaseManager.configure()
try AuthManager.shared.configure()

// Wrong order
try AuthManager.shared.configure() // Throws error!
FirebaseManager.configure()
```

### "GoogleService-Info.plist not found"

**Problem**: App crashes at launch with plist error.

**Solutions**:
1. Verify the file is in your app target (not the package)
2. Check "Target Membership" in Xcode
3. Clean build folder (⇧⌘K)

### "Permission denied" Errors

**Problem**: Firestore operations fail with permission errors.

**Solution**: Update your Firestore security rules in Firebase Console.

Development rules (INSECURE, for testing only):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

Production rules (SECURE):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Next Steps

- Learn about multi-app setup: <doc:MultiAppSetup>
- Security best practices: <doc:SecurityBestPractices>
