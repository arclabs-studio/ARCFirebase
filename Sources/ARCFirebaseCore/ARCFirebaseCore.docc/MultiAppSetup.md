# Multi-App Firebase Setup

How to use ARCFirebase across multiple apps, each backed by its own Firebase project.

## Overview

ARCFirebase is designed to be reused across multiple apps. Each app uses the same package but connects to its own Firebase project.

## Architecture

```
ARCFirebase Package (Shared)
    ├── Core
    ├── Auth
    ├── Analytics
    ├── Crashlytics
    ├── Persistence
    └── Storage

AppA                            AppB
├── GoogleService-Info.plist    ├── GoogleService-Info.plist
│   (AppA project)              │   (AppB project)
└── Uses ARCFirebase            └── Uses ARCFirebase
```

**Key principle**: The **package is shared**, but each app has its **own GoogleService-Info.plist**.

## Setup for Each App

### 1. Create Separate Firebase Projects

For each app, create a Firebase project:

- **AppA**: Project "AppA" (appa-ios)
- **AppB**: Project "AppB" (appb-ios)
- **AppC**: Project "AppC" (appc-ios)

### 2. Download Separate Config Files

Each app gets its own `GoogleService-Info.plist`:

```
~/Documents/Firebase-Configs/
├── AppA-GoogleService-Info.plist
├── AppB-GoogleService-Info.plist
└── AppC-GoogleService-Info.plist
```

### 3. Add to Correct App Target

**CRITICAL**: Add the correct plist to each app.

```
AppA/
└── GoogleService-Info.plist  ← AppA config

AppB/
└── GoogleService-Info.plist  ← AppB config (DIFFERENT file!)
```

### 4. Verify Bundle IDs Match

Your Firebase console settings must match your Xcode bundle IDs:

| App | Firebase Console | Xcode Bundle ID |
|-----|-----------------|-----------------|
| AppA | com.example.appA | com.example.appA |
| AppB | com.example.appB | com.example.appB |

## Code Reuse

The beautiful part: **Your code doesn't change**.

```swift
// AppA.swift
import ARCFirebaseCore

@main
struct AppA: App {
    init() {
        FirebaseManager.configure() // Reads AppA config
    }
}

// AppB.swift
import ARCFirebaseCore

@main
struct AppB: App {
    init() {
        FirebaseManager.configure() // Reads AppB config
    }
}
```

**Same code**, **different Firebase projects** based on which `GoogleService-Info.plist` is included.

## Data Isolation

Each app has **completely separate data**:

### AppA Firebase Project
```
Firestore:
├── items/
├── users/
└── favorites/
```

### AppB Firebase Project
```
Firestore:
├── posts/
├── users/  ← Different users than AppA
└── lists/
```

Users in AppA **cannot** access data from AppB (and vice versa).

## Shared Code Patterns

### Repository Pattern

```swift
// Shared in ARCFirebase package
public final class FirestoreRepository<Entity> { ... }

// Used differently in each app
// AppA:
let itemRepo = try FirestoreRepository<Item>(
    collectionPath: "items"
)

// AppB:
let postRepo = try FirestoreRepository<Post>(
    collectionPath: "posts"
)
```

### Analytics Events

Define common events once, use everywhere:

```swift
// In ARCFirebaseAnalytics
public struct AnalyticsEvent {
    public static let itemViewed = "item_viewed"
    public static let itemFavorited = "item_favorited"
}

// AppA
AnalyticsManager.shared.logEvent(
    AnalyticsEvent.itemViewed,
    parameters: ["item_type": "product"]
)

// AppB
AnalyticsManager.shared.logEvent(
    AnalyticsEvent.itemViewed,
    parameters: ["item_type": "post"]
)
```

## Common Mistakes

### Mistake 1: Using Same Firebase Project

**Problem**: All apps point to the same Firebase project.

**Result**: AppA and AppB share users and data (BAD!).

**Solution**: Create separate Firebase projects.

### Mistake 2: Wrong plist in App

**Problem**: AppB has AppA's `GoogleService-Info.plist`.

**Result**: AppB writes data to AppA's Firebase project.

**Solution**: Double-check each app has the correct plist.

### Mistake 3: Committing plist to Git

**Problem**: `GoogleService-Info.plist` in version control.

**Security risk**: API keys exposed.

**Solution**: Add to `.gitignore`:

```gitignore
GoogleService-Info.plist
```

## Summary

**DO**:
- Create separate Firebase projects per app
- Use the same ARCFirebase package for all apps
- Keep `GoogleService-Info.plist` files separate
- Add plists to `.gitignore`

**DON'T**:
- Share Firebase projects between apps
- Mix up config files
- Commit plists to Git
- Hardcode Firebase credentials in code

The ARCFirebase package is **fully reusable**—just swap the config file!
