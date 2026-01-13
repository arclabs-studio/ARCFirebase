# ``ARCFirebaseAnalytics``

Firebase Analytics integration for tracking user behavior and app performance.

## Overview

ARCFirebaseAnalytics provides a type-safe interface to Firebase Analytics, making it easy to track events, user properties, and screen views.

The module follows a protocol-based architecture for testability and flexibility, allowing you to easily swap implementations or use mocks in tests.

## Key Features

- **Protocol-based design**: Use `AnalyticsProviding` for dependency injection
- **Event tracking**: Log custom events with parameters
- **User properties**: Define user segments
- **Screen tracking**: Monitor navigation patterns
- **Predefined events**: Common event types for consistency
- **SwiftUI integration**: Environment values support
- **Logging**: ARCLogger integration for debugging

## Topics

### Getting Started

- <doc:EventTrackingGuide>

### Protocols

- ``AnalyticsProviding``

### Implementations

- ``FirebaseAnalyticsProvider``
- ``FirebaseAnalyticsProvider/logEvent(_:parameters:)``
- ``FirebaseAnalyticsProvider/logScreenView(_:screenClass:)``

### SwiftUI Integration

- ``AnalyticsProviderKey``

### User Properties

- ``AnalyticsProviding/setUserProperty(_:value:)``
- ``AnalyticsProviding/setUserID(_:)``

### Common Events

- ``AnalyticsEvent``
- ``AnalyticsParameter``
