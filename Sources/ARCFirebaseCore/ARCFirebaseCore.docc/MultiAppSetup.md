# Multi-App Firebase Setup

How to use ARCFirebase across multiple ARC Labs Studio apps.

## Overview

ARCFirebase is designed to be reused across all ARC Labs apps (FavRes, FavBook, Spatial Shoes, etc.). Each app uses the same package but connects to its own Firebase project.

## Architecture

```
ARCFirebase Package (Shared)
    ├── Core
    ├── Auth
    ├── Analytics
    ├── Crashlytics
    ├── Persistence
    └── Storage

FavRes App                      FavBook App
├── GoogleService-Info.plist    ├── GoogleService-Info.plist
│   (FavRes project)            │   (FavBook project)
└── Uses ARCFirebase            └── Uses ARCFirebase
```

**Key principle**: The **package is shared**, but each app has its **own GoogleService-Info.plist**.

## Setup for Each App

### 1. Create Separate Firebase Projects

For each app, create a Firebase project:

- **FavRes**: Project "FavRes" (favres-ios)
- **FavBook**: Project "FavBook" (favbook-ios)
- **Spatial Shoes**: Project "Spatial Shoes" (spatial-shoes-ios)

### 2. Download Separate Config Files

Each app gets its own `GoogleService-Info.plist`:

```
~/Documents/ARC-Labs-Firebase/
├── FavRes-GoogleService-Info.plist
├── FavBook-GoogleService-Info.plist
└── SpatialShoes-GoogleService-Info.plist
```

### 3. Add to Correct App Target

**CRITICAL**: Add the correct plist to each app.

```
FavRes/
└── GoogleService-Info.plist  ← FavRes config

FavBook/
└── GoogleService-Info.plist  ← FavBook config (DIFFERENT file!)
```

### 4. Verify Bundle IDs Match

Your Firebase console settings must match your Xcode bundle IDs:

| App | Firebase Console | Xcode Bundle ID |
|-----|-----------------|-----------------|
| FavRes | com.arclabs.favres | com.arclabs.favres |
| FavBook | com.arclabs.favbook | com.arclabs.favbook |

## Code Reuse

The beautiful part: **Your code doesn't change**.

```swift
// FavResApp.swift
import ARCFirebaseCore

@main
struct FavResApp: App {
    init() {
        FirebaseManager.configure() // Reads FavRes config
    }
}

// FavBookApp.swift
import ARCFirebaseCore

@main
struct FavBookApp: App {
    init() {
        FirebaseManager.configure() // Reads FavBook config
    }
}
```

**Same code**, **different Firebase projects** based on which `GoogleService-Info.plist` is included.

## Data Isolation

Each app has **completely separate data**:

### FavRes Firebase Project
```
Firestore:
├── restaurants/
├── users/
└── favorites/
```

### FavBook Firebase Project
```
Firestore:
├── books/
├── users/  ← Different users than FavRes
└── readingLists/
```

Users in FavRes **cannot** access data from FavBook (and vice versa).

## Shared Code Patterns

### Repository Pattern

```swift
// Shared in ARCFirebase package
public final class FirestoreRepository<Entity> { ... }

// Used differently in each app
// FavRes:
let restaurantRepo = try FirestoreRepository<Restaurant>(
    collectionPath: "restaurants"
)

// FavBook:
let bookRepo = try FirestoreRepository<Book>(
    collectionPath: "books"
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

// FavRes
AnalyticsManager.shared.logEvent(
    AnalyticsEvent.itemViewed,
    parameters: ["item_type": "restaurant"]
)

// FavBook
AnalyticsManager.shared.logEvent(
    AnalyticsEvent.itemViewed,
    parameters: ["item_type": "book"]
)
```

## Common Mistakes

### Mistake 1: Using Same Firebase Project

**Problem**: All apps point to the same Firebase project.

**Result**: FavRes and FavBook share users and data (BAD!).

**Solution**: Create separate Firebase projects.

### Mistake 2: Wrong plist in App

**Problem**: FavBook has FavRes's `GoogleService-Info.plist`.

**Result**: FavBook writes data to FavRes's Firebase project.

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
