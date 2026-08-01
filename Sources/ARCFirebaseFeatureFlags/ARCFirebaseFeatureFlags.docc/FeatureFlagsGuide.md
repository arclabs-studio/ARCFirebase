# Feature Flags Guide

Learn how to use Firebase Remote Config for feature flags and remote configuration.

## Overview

This guide covers setting up feature flags, reading typed values, listening for real-time updates, and integrating with SwiftUI using the protocol-based architecture for dependency injection and testability.

## Basic Setup

### Production Setup

```swift
import ARCFirebaseFeatureFlags
import ARCFirebaseCore

// Configure Firebase at app launch
FirebaseManager.configure()

// Create the feature flag provider
let flags = try FirebaseFeatureFlagProvider()

// Or use the convenience accessor
let flags = FirebaseFeatureFlagProvider.live
```

### Configuration Presets

```swift
// Development: No fetch throttle (for rapid iteration)
let flags = try FirebaseFeatureFlagProvider(configuration: .development)

// Production: 12-hour cache (recommended for release)
let flags = try FirebaseFeatureFlagProvider(configuration: .production)

// Custom interval
let config = FeatureFlagConfiguration(minimumFetchInterval: 3600) // 1 hour
let flags = try FirebaseFeatureFlagProvider(configuration: config)
```

### Dependency Injection

For better testability, inject the feature flag provider into your classes:

```swift
class FeatureManager {
    private let flags: any FeatureFlagProviding

    init(flags: any FeatureFlagProviding) {
        self.flags = flags
    }

    func isNewOnboardingEnabled() -> Bool {
        flags.isEnabled("new_onboarding_v2")
    }

    func maxUploadSize() -> Int {
        flags.int(forKey: "max_upload_size_mb", defaultValue: 10)
    }
}

// Production
let manager = FeatureManager(flags: FirebaseFeatureFlagProvider.live)

// Testing
let mock = MockFeatureFlagProvider()
mock.mockFlags["new_onboarding_v2"] = true
let manager = FeatureManager(flags: mock)
```

## Fetching Values

### Fetch and Activate

Always fetch the latest config values at app launch:

```swift
let flags = try FirebaseFeatureFlagProvider(configuration: .production)

// Fetch latest values from Firebase
try await flags.fetchAndActivate()
```

### Setting Defaults

Set default values before fetching. These are used when no remote value has been fetched yet:

```swift
flags.setDefaults([
    "new_onboarding_v2": false,
    "max_upload_size_mb": 10,
    "welcome_message": "Welcome!",
    "api_timeout_seconds": 30.0
])
```

## Reading Values

### Boolean Flags

```swift
// With explicit default
let isEnabled = flags.bool(forKey: "premium_features", defaultValue: false)

// Convenience (defaults to false)
let isEnabled = flags.isEnabled("premium_features")

// Convenience without default
let isEnabled = flags.bool(forKey: "premium_features")
```

### String Values

```swift
let message = flags.string(forKey: "welcome_message", defaultValue: "Hello!")
let version = flags.string(forKey: "min_app_version") // defaults to ""
```

### Numeric Values

```swift
let maxSize = flags.int(forKey: "max_upload_size_mb", defaultValue: 10)
let timeout = flags.double(forKey: "api_timeout_seconds", defaultValue: 30.0)
```

### Data Values

```swift
let payload = flags.data(forKey: "config_payload", defaultValue: Data())
```

## Real-Time Updates

Listen for config changes without polling:

```swift
// Listen for updates in a Task
Task {
    for await _ in flags.configUpdates() {
        // Config was updated and auto-activated
        let newValue = flags.isEnabled("new_feature")
        print("Feature updated: \(newValue)")
    }
}
```

## SwiftUI Integration

### Environment Values

Use SwiftUI's environment to pass the provider through your view hierarchy:

```swift
import SwiftUI
import ARCFirebaseFeatureFlags

@main
struct MyApp: App {
    let flags = FirebaseFeatureFlagProvider.live

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.featureFlagProvider, flags)
        }
    }
}
```

### Using in Views

```swift
struct FeatureGatedView: View {
    @Environment(\.featureFlagProvider) private var flags

    var body: some View {
        VStack {
            if flags.isEnabled("new_onboarding_v2") {
                NewOnboardingView()
            } else {
                LegacyOnboardingView()
            }

            Text(flags.string(forKey: "welcome_message", defaultValue: "Welcome!"))
        }
        .task {
            try? await flags.fetchAndActivate()
        }
    }
}
```

### Using with ViewModel

```swift
@MainActor
@Observable
final class HomeViewModel {
    private let flags: any FeatureFlagProviding

    var showPremiumBanner: Bool {
        flags.isEnabled("show_premium_banner")
    }

    var maxItems: Int {
        flags.int(forKey: "max_items", defaultValue: 50)
    }

    init(flags: any FeatureFlagProviding) {
        self.flags = flags
    }

    func refreshFlags() async {
        try? await flags.fetchAndActivate()
    }
}
```

## Best Practices

### Use Descriptive Flag Names

```swift
// Good: descriptive, versioned
flags.isEnabled("new_onboarding_v2")
flags.int(forKey: "max_upload_size_mb")

// Bad: ambiguous
flags.isEnabled("flag1")
flags.int(forKey: "size")
```

### Always Set Defaults

```swift
// Set defaults before any reads
flags.setDefaults([
    "new_onboarding_v2": false,
    "max_retries": 3
])

// Now reads have reliable fallbacks
let enabled = flags.isEnabled("new_onboarding_v2")
```

### Use Development Configuration During Development

```swift
#if DEBUG
let config = FeatureFlagConfiguration.development
#else
let config = FeatureFlagConfiguration.production
#endif

let flags = try FirebaseFeatureFlagProvider(configuration: config)
```

### Clean Up Old Flags

Remove flags from your codebase after they have been fully rolled out to avoid dead code.

## Testing with Mocks

Create a mock provider for testing:

```swift
final class MockFeatureFlagProvider: FeatureFlagProviding, @unchecked Sendable {
    var mockFlags: [String: any Sendable] = [:]

    func fetchAndActivate() async throws { }
    func setDefaults(_ defaults: [String: any Sendable]) { }

    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        mockFlags[key] as? Bool ?? defaultValue
    }

    func string(forKey key: String, defaultValue: String) -> String {
        mockFlags[key] as? String ?? defaultValue
    }

    func int(forKey key: String, defaultValue: Int) -> Int {
        mockFlags[key] as? Int ?? defaultValue
    }

    func double(forKey key: String, defaultValue: Double) -> Double {
        mockFlags[key] as? Double ?? defaultValue
    }

    func data(forKey key: String, defaultValue: Data) -> Data {
        mockFlags[key] as? Data ?? defaultValue
    }

    func configUpdates() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }
}

// In tests
@Test("Premium banner shows when flag enabled")
func premiumBanner_whenEnabled() {
    let mock = MockFeatureFlagProvider()
    mock.mockFlags["show_premium_banner"] = true

    let viewModel = HomeViewModel(flags: mock)

    #expect(viewModel.showPremiumBanner == true)
}
```

## Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Remote Config** (under Build or Run)
4. Add parameters:
   - `new_onboarding_v2` (Boolean) = `false`
   - `max_upload_size_mb` (Number) = `10`
   - `welcome_message` (String) = `"Welcome!"`
5. Click **Publish changes**
6. Values will be fetched on next `fetchAndActivate()` call

## See Also

- ``FeatureFlagProviding``
- ``FirebaseFeatureFlagProvider``
- ``FeatureFlagConfiguration``
