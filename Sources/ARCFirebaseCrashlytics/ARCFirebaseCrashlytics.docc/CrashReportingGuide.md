# Crash Reporting Guide

Learn how to implement crash reporting and error tracking in your app.

## Overview

This guide covers setting up Crashlytics and tracking errors effectively.

## Basic Setup

```swift
import ARCFirebaseCrashlytics

// Configure at app launch
FirebaseManager.configure()
try CrashlyticsManager.shared.configure()
```

## Recording Errors

### Caught Exceptions

```swift
do {
    try await repository.save(item)
} catch {
    CrashlyticsManager.shared.record(error: error)
    // Show error to user
}
```

### Non-Fatal Errors

```swift
if let validationError = validate(input) {
    CrashlyticsManager.shared.recordNonFatal(error: validationError)
}
```

## Custom Logs

Add breadcrumbs to understand user actions before a crash:

```swift
CrashlyticsManager.shared.log("User opened restaurant detail: \(restaurantID)")
CrashlyticsManager.shared.log("User tapped favorite button")
CrashlyticsManager.shared.log("Attempting to save favorite to Firestore")
```

## User Identification

Associate crashes with specific users:

```swift
// After user signs in
CrashlyticsManager.shared.setUserID(user.id)
```

## Custom Values

Add app state to crash reports:

```swift
CrashlyticsManager.shared.setCustomValue(theme, forKey: "app_theme")
CrashlyticsManager.shared.setCustomValue(isPremium, forKey: "is_premium")
CrashlyticsManager.shared.setCustomValue(lastScreen, forKey: "last_screen")
```

## Testing Crashlytics

### Force a Test Crash

```swift
#if DEBUG
Button("Test Crash") {
    fatalError("Test crash for Crashlytics")
}
#endif
```

### Verify Setup

1. Run app
2. Trigger test crash
3. Reopen app
4. Check Firebase Console → Crashlytics (may take a few minutes)

## Best Practices

### Don't Log PII

```swift
// BAD
CrashlyticsManager.shared.setUserID(user.email)

// GOOD
CrashlyticsManager.shared.setUserID(user.id)
```

### Add Context

```swift
// Add relevant context before operations
CrashlyticsManager.shared.log("Starting sync with \(items.count) items")
CrashlyticsManager.shared.setCustomValue(items.count, forKey: "sync_item_count")

do {
    try await syncItems(items)
} catch {
    CrashlyticsManager.shared.record(error: error)
}
```

### Catch and Report

```swift
// Good pattern for async operations
Task {
    do {
        try await performNetworkRequest()
    } catch {
        CrashlyticsManager.shared.record(error: error)
        logger.error("Network request failed: \(error)")
    }
}
```

## See Also

- ``CrashlyticsManager``
- <doc:/ARCFirebaseCore/SecurityBestPractices>
