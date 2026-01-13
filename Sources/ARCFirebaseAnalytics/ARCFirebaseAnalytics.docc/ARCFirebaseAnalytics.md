# ``ARCFirebaseAnalytics``

Firebase Analytics integration for tracking user behavior and app performance.

## Overview

ARCFirebaseAnalytics provides a type-safe interface to Firebase Analytics, making it easy to track events, user properties, and screen views.

## Key Features

- **Event tracking**: Log custom events with parameters
- **User properties**: Define user segments
- **Screen tracking**: Monitor navigation patterns
- **Predefined events**: Common event types for consistency

## Topics

### Getting Started

- <doc:EventTrackingGuide>

### Event Tracking

- ``AnalyticsManager``
- ``AnalyticsManager/logEvent(_:parameters:)``
- ``AnalyticsManager/logScreenView(_:screenClass:)``

### User Properties

- ``AnalyticsManager/setUserProperty(_:value:)``
- ``AnalyticsManager/setUserID(_:)``

### Common Events

- ``AnalyticsEvent``
- ``AnalyticsParameter``
