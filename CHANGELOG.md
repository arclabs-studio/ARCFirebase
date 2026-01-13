# Changelog

All notable changes to ARCFirebase will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-13

### Added

#### ARCFirebaseCore
- `FirebaseManager` singleton for Firebase configuration management
- `FirebaseError` enum with comprehensive error types and descriptions
- `Error+Firebase` extension for error conversion

#### ARCFirebaseAuth
- `AuthProviding` protocol for dependency injection
- `FirebaseAuthProvider` class with full authentication support
- `AuthProviderKey` for SwiftUI Environment integration
- `User` model with Firebase user mapping
- Factory methods: `create()` and `live` property

#### ARCFirebaseAnalytics
- `AnalyticsProviding` protocol for dependency injection
- `FirebaseAnalyticsProvider` class for event tracking
- `AnalyticsProviderKey` for SwiftUI Environment integration
- `AnalyticsEvent` and `AnalyticsParameter` predefined constants
- Factory methods: `create()` and `live` property

#### ARCFirebaseCrashlytics
- `CrashlyticsProviding` protocol for dependency injection
- `FirebaseCrashlyticsProvider` class for crash reporting
- `CrashlyticsProviderKey` for SwiftUI Environment integration
- Support for error recording, logging, user context, and custom values
- Factory methods: `create()` and `live` property

#### ARCFirebasePersistence
- `Repository` protocol for generic CRUD operations
- `FirestoreRepository<T>` generic implementation with advanced queries
- `FirestoreDocument` protocol with timestamp helpers
- Support for equality queries, ordering, and limits

#### ARCFirebaseStorage
- `StorageProviding` protocol for dependency injection
- `FirebaseStorageProvider` class for cloud storage operations
- `StorageProviderKey` for SwiftUI Environment integration
- `StorageReference` type-safe path builder with helpers
- Factory methods: `create()` and `live` property

### Testing
- Comprehensive mock providers for all modules
- 64 unit tests covering all protocols and implementations
- Swift Testing framework integration

### Documentation
- DocC documentation for all modules
- Comprehensive README with usage examples
- CLAUDE.md with project guidelines

### Infrastructure
- ARCDevTools integration with SwiftLint and SwiftFormat
- Git hooks for pre-commit and pre-push quality checks
- Swift 6.0 strict concurrency compliance
- Support for iOS 17+, macOS 14+, watchOS 10+, visionOS 1+

---

## [Unreleased]

### Changed

#### ARCFirebaseAnalytics
- Converted `FirebaseAnalyticsProvider` from `class @unchecked Sendable` to `actor`
  - Methods are `nonisolated` since Firebase Analytics SDK is internally thread-safe
  - Eliminates need for `@unchecked Sendable` annotation

#### ARCFirebaseCore
- Added `FirebaseConfiguring` protocol for dependency injection
  - Enables testing of code that depends on Firebase configuration
  - `FirebaseManager` now conforms to `FirebaseConfiguring`
  - Includes usage examples for production and testing in documentation

#### ARCFirebaseStorage
- Added `StorageConfiguration` struct for configurable download limits
  - `maxDownloadSize` property (default: 10 MB)
  - Preset configurations: `.default` (10 MB) and `.largeFiles` (50 MB)
  - New initializer: `FirebaseStorageProvider(configuration:)`

### Planned
- Integration tests with Firebase emulator
- Additional query methods for FirestoreRepository
- Batch operations support for Persistence module
