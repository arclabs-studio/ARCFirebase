# ``ARCFirebase``

Modular Firebase integration for ARC Labs Studio apps.

## Overview

ARCFirebase provides a clean, modular architecture for integrating Firebase services into Swift applications. Each Firebase service is wrapped in a protocol-based abstraction that enables dependency injection and comprehensive testing.

### Key Features

- **Modular architecture**: Import only what you need
- **Protocol-based design**: Dependency injection for testability
- **Type-safe APIs**: Swift-first, async/await throughout
- **Actor-based**: Thread-safe with Swift concurrency
- **SwiftUI integration**: Environment values support

## Topics

### Essentials

- ``ARCFirebaseCore``
- ``FirebaseManager``

### Authentication

- ``ARCFirebaseAuth``
- ``AuthProviding``
- ``FirebaseAuthProvider``

### Analytics

- ``ARCFirebaseAnalytics``
- ``AnalyticsProviding``
- ``FirebaseAnalyticsProvider``

### Crashlytics

- ``ARCFirebaseCrashlytics``
- ``CrashlyticsProviding``
- ``FirebaseCrashlyticsProvider``

### Persistence

- ``ARCFirebasePersistence``
- ``Repository``
- ``FirestoreRepository``

### Storage

- ``ARCFirebaseStorage``
- ``StorageProviding``
- ``FirebaseStorageProvider``
