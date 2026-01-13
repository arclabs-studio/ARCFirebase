# Event Tracking Guide

Learn how to track user behavior and app performance with Firebase Analytics.

## Overview

This guide covers best practices for implementing analytics in your app using the protocol-based architecture for dependency injection and testability.

## Basic Setup

### Production Setup

```swift
import ARCFirebaseAnalytics
import ARCFirebaseCore

// Configure Firebase at app launch
FirebaseManager.configure()

// Create the analytics provider
let analytics = FirebaseAnalyticsProvider.live
```

### Dependency Injection

For better testability, inject the analytics provider into your classes:

```swift
class ItemViewModel {
    private let analytics: any AnalyticsProviding

    init(analytics: any AnalyticsProviding) {
        self.analytics = analytics
    }

    func trackItemView(itemID: String) {
        analytics.logEvent(AnalyticsEvent.itemViewed, parameters: [
            AnalyticsParameter.itemID: itemID
        ])
    }
}

// Production
let viewModel = ItemViewModel(analytics: FirebaseAnalyticsProvider.live)

// Testing
let viewModel = ItemViewModel(analytics: MockAnalyticsProvider())
```

## Logging Events

### Custom Events

```swift
let analytics = FirebaseAnalyticsProvider.live

analytics.logEvent("restaurant_viewed", parameters: [
    "restaurant_id": "abc123",
    "category": "italian",
    "rating": 4.5
])
```

### Predefined Events

Use predefined event names for consistency:

```swift
let analytics = FirebaseAnalyticsProvider.live

analytics.logEvent(
    AnalyticsEvent.itemViewed,
    parameters: [
        AnalyticsParameter.itemID: restaurant.id,
        AnalyticsParameter.itemCategory: restaurant.category
    ]
)
```

## Screen Tracking

### SwiftUI Integration

Use SwiftUI's environment to access the analytics provider:

```swift
import SwiftUI
import ARCFirebaseAnalytics

@main
struct MyApp: App {
    let analytics = FirebaseAnalyticsProvider.live

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.analyticsProvider, analytics)
        }
    }
}

struct RestaurantDetailView: View {
    @Environment(\.analyticsProvider) var analytics

    var body: some View {
        VStack {
            // Your UI
        }
        .onAppear {
            analytics.logScreenView(
                "RestaurantDetail",
                screenClass: "RestaurantDetailView"
            )
        }
    }
}
```

### Standard Usage

Track screen views without SwiftUI:

```swift
let analytics = FirebaseAnalyticsProvider.live

analytics.logScreenView(
    "RestaurantDetail",
    screenClass: "RestaurantDetailViewController"
)
```

## User Properties

Set properties to segment your users:

```swift
let analytics = FirebaseAnalyticsProvider.live

// After user signs in
analytics.setUserID(user.id)
analytics.setUserProperty("account_type", value: "premium")
analytics.setUserProperty("preferred_cuisine", value: "italian")
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
let analytics = FirebaseAnalyticsProvider.live

// GOOD - Anonymous user ID
analytics.setUserID(user.id)

// BAD - PII in analytics
analytics.setUserID(user.email) // Don't do this!
```

## Common Events for ARC Labs Apps

### E-commerce

```swift
let analytics = FirebaseAnalyticsProvider.live

// Item viewed
analytics.logEvent(AnalyticsEvent.itemViewed, parameters: [
    AnalyticsParameter.itemID: item.id,
    AnalyticsParameter.itemCategory: item.category
])

// Item favorited
analytics.logEvent(AnalyticsEvent.itemFavorited, parameters: [
    AnalyticsParameter.itemID: item.id
])

// Item shared
analytics.logEvent(AnalyticsEvent.itemShared, parameters: [
    AnalyticsParameter.itemID: item.id,
    "share_method": "twitter"
])
```

### Search

```swift
let analytics = FirebaseAnalyticsProvider.live

analytics.logEvent(AnalyticsEvent.searchPerformed, parameters: [
    AnalyticsParameter.searchQuery: query,
    "results_count": results.count
])
```

### Onboarding

```swift
let analytics = FirebaseAnalyticsProvider.live

analytics.logEvent(
    AnalyticsEvent.onboardingCompleted,
    parameters: ["duration_seconds": duration]
)
```

## Testing with Mocks

Create a mock provider for testing:

```swift
final class MockAnalyticsProvider: AnalyticsProviding {
    var loggedEvents: [(name: String, parameters: [String: Any]?)] = []

    func logEvent(_ name: String, parameters: [String: Any]?) {
        loggedEvents.append((name, parameters))
    }

    func logScreenView(_ screenName: String, screenClass: String?) {}
    func setUserProperty(_ name: String, value: String?) {}
    func setUserID(_ userID: String?) {}
}

// In tests
func testEventLogging() {
    let mock = MockAnalyticsProvider()
    let viewModel = ItemViewModel(analytics: mock)

    viewModel.trackItemView(itemID: "123")

    #expect(mock.loggedEvents.count == 1)
    #expect(mock.loggedEvents[0].name == AnalyticsEvent.itemViewed)
}
```

## See Also

- ``AnalyticsProviding``
- ``FirebaseAnalyticsProvider``
- ``AnalyticsEvent``
- ``AnalyticsParameter``
