# ``ARCFirebaseFeatureFlags``

Firebase Remote Config integration for feature flags and remote configuration.

## Overview

ARCFirebaseFeatureFlags provides a simplified, type-safe interface to Firebase Remote Config for managing feature flags, A/B testing, and remote configuration values without app updates.

The module follows a protocol-based architecture for testability and flexibility, allowing you to easily swap implementations or use mocks in tests.

## Key Features

- **Protocol-based design**: Use `FeatureFlagProviding` for dependency injection
- **Type-safe accessors**: Read Bool, String, Int, Double, and Data values
- **Convenience defaults**: `isEnabled(_:)` for quick boolean checks
- **Real-time updates**: Listen for config changes via `configUpdates()`
- **Configurable fetch intervals**: Development, production, and custom presets
- **SwiftUI integration**: Environment values support
- **Logging**: ARCLogger integration for debugging

## Topics

### Getting Started

- <doc:FeatureFlagsGuide>

### Protocols

- ``FeatureFlagProviding``

### Implementations

- ``FirebaseFeatureFlagProvider``

### Configuration

- ``FeatureFlagConfiguration``

### Fetching & Defaults

- ``FeatureFlagProviding/fetchAndActivate()``
- ``FeatureFlagProviding/setDefaults(_:)``

### Reading Values

- ``FeatureFlagProviding/bool(forKey:defaultValue:)``
- ``FeatureFlagProviding/string(forKey:defaultValue:)``
- ``FeatureFlagProviding/int(forKey:defaultValue:)``
- ``FeatureFlagProviding/double(forKey:defaultValue:)``
- ``FeatureFlagProviding/data(forKey:defaultValue:)``
- ``FeatureFlagProviding/isEnabled(_:)``

### Real-Time Updates

- ``FeatureFlagProviding/configUpdates()``
