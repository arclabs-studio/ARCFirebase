# Event Tracking Guide

Learn how to track user behavior and app performance with Firebase Analytics.

## Overview

This guide covers best practices for implementing analytics in your app.

## Basic Setup

```swift
import ARCFirebaseAnalytics

// Configure at app launch
FirebaseManager.configure()
try AnalyticsManager.shared.configure()
```

## Logging Events

### Custom Events

```swift
AnalyticsManager.shared.logEvent("restaurant_viewed", parameters: [
    "restaurant_id": "abc123",
    "category": "italian",
    "rating": 4.5
])
```

### Predefined Events

Use predefined event names for consistency:

```swift
AnalyticsManager.shared.logEvent(
    AnalyticsEvent.itemViewed,
    parameters: [
        AnalyticsParameter.itemID: restaurant.id,
        AnalyticsParameter.itemCategory: restaurant.category
    ]
)
```

## Screen Tracking

Track which screens users visit:

```swift
struct RestaurantDetailView: View {
    var body: some View {
        VStack {
            // Your UI
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(
                "RestaurantDetail",
                screenClass: "RestaurantDetailView"
            )
        }
    }
}
```

## User Properties

Set properties to segment your users:

```swift
// After user signs in
AnalyticsManager.shared.setUserID(user.id)
AnalyticsManager.shared.setUserProperty("account_type", value: "premium")
AnalyticsManager.shared.setUserProperty("preferred_cuisine", value: "italian")
```

## Best Practices

### Event Naming

- Use lowercase with underscores: `item_viewed`
- Be specific but concise: `restaurant_favorited` not just `favorited`
- Max 40 characters

### Parameters

- Max 25 parameters per event
- Use consistent parameter names across events
- Don't log PII (personally identifiable information)

### Privacy

```swift
// GOOD - Anonymous user ID
AnalyticsManager.shared.setUserID(user.id)

// BAD - PII in analytics
AnalyticsManager.shared.setUserID(user.email) // Don't do this!
```

## Common Events for ARC Labs Apps

### E-commerce

```swift
// Item viewed
AnalyticsManager.shared.logEvent(AnalyticsEvent.itemViewed, parameters: [
    AnalyticsParameter.itemID: item.id,
    AnalyticsParameter.itemCategory: item.category
])

// Item favorited
AnalyticsManager.shared.logEvent(AnalyticsEvent.itemFavorited, parameters: [
    AnalyticsParameter.itemID: item.id
])

// Item shared
AnalyticsManager.shared.logEvent(AnalyticsEvent.itemShared, parameters: [
    AnalyticsParameter.itemID: item.id,
    "share_method": "twitter"
])
```

### Search

```swift
AnalyticsManager.shared.logEvent(AnalyticsEvent.searchPerformed, parameters: [
    AnalyticsParameter.searchQuery: query,
    "results_count": results.count
])
```

### Onboarding

```swift
AnalyticsManager.shared.logEvent(
    AnalyticsEvent.onboardingCompleted,
    parameters: ["duration_seconds": duration]
)
```

## See Also

- ``AnalyticsManager``
- ``AnalyticsEvent``
- ``AnalyticsParameter``
