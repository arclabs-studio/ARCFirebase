# Changelog

All notable changes to ARCFirebase will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-09-09

### Added

#### ARCFirebaseAuth
- `AuthProviding.revokeToken(authorizationCode:)` — revokes a user's Apple tokens ahead of
  account deletion, as Apple requires of apps offering Sign in with Apple. Must be called
  while the user is still signed in; the authorization code must be freshly obtained, since
  Apple's codes are single-use and expire within minutes.
- `AuthProviding.reauthenticate(with:)` — clears `FirebaseError.requiresRecentLogin` before
  a security-sensitive operation such as account deletion.
- `OAuthCredentialData.authorizationCode` — optional, defaulted, so existing call sites are
  unaffected. Consumed only by `revokeToken(authorizationCode:)`; it is not part of the
  credential Firebase builds for sign-in.

### Notes

- `revokeToken` requires the *Services ID* and *OAuth code flow configuration* to be filled
  in on the Apple provider in the Firebase console. Without them the backend cannot exchange
  the code with Apple and the call fails with `Code flow is not enabled for Apple`.

## [1.1.0] - 2026-09-01

### Added

#### ARCFirebaseAI
- `AISafetySetting` — provider-agnostic safety filter setting, with `Category`
  (`harassment`, `hateSpeech`, `sexuallyExplicit`, `dangerousContent`) and `Threshold`
  (`blockLowAndAbove`, `blockMediumAndAbove`, `blockOnlyHigh`, …). Mapped to
  `FirebaseAI.SafetySetting` at the provider boundary.
- `AIConfiguration.safetySettings: [AISafetySetting]?` — optional and defaulted to `nil`,
  which leaves the provider's own defaults in place. `AISafetySetting.standardModeration`
  supplies the recommended baseline.

## [1.0.0] - 2026-08-20

First public release of **ARCFirebase**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (0.1.0 → 1.0.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

#### ARCFirebaseAuth
- `sendEmailVerification()` to `AuthProviding` protocol and `FirebaseAuthProvider`

#### ARCFirebaseCore
- `ARCFirebaseLogSubsystem` helper — derives logger subsystem from
  `Bundle.main.bundleIdentifier` at runtime, falling back to
  `com.arclabs-studio.arcfirebase`. Scopes os_log streams to the host app.

#### ARCFirebaseAI
- `GeminiModel.pro25` (`gemini-2.5-pro`)
- `GeminiModel.flashLite25` (`gemini-2.5-flash-lite`)
- `GeminiModel.flashLite20` (`gemini-2.0-flash-lite`)

#### ARCFirebaseAI
- `AIProviding` protocol for dependency injection of AI content generation
- `FirebaseAIProvider` class using Firebase AI (Gemini) for production use
- `AIProviderKey` for SwiftUI Environment integration
- `AIConfiguration` struct with presets: `.default`, `.creative`, `.factual`, `.structured`
- `AIResponse` model with finish reason and token usage metadata
- `AIMessage` model for multi-turn chat conversations
- Streaming content generation via `AsyncThrowingStream`
- Structured output generation with Firebase `Schema` type
- System instruction support for guided model behavior
- Factory methods: `create(model:)` and `live` property
- DocC documentation with Getting Started guide

#### ARCFirebaseCore
- Added `case aiNotAvailable` to `FirebaseError`

### Fixed

- **Duplicate `## [Unreleased]` headings** — this file carried two, and release tooling parses only the first, silently dropping the second block. Both are now folded into this release.

### Changed

#### ARCFirebaseCore / all providers
- All 10 providers now use `ARCFirebaseLogSubsystem.current` instead of the
  hardcoded `"com.arclabs-studio.arcfirebase"` subsystem. No API change.

#### ARCFirebaseAppCheck
- `FirebaseAppCheckProvider.configure()` no-op path now logs at `.info` level
  with an explicit reason (instead of silent `.debug`). Docstring expanded to
  warn that App Check factories must be installed before `FirebaseApp.configure()`
  and that `FirebaseManager.configure(appCheckProvider:)` is the recommended path.

#### ARCFirebaseAI
- `FirebaseAIProvider` now logs a rich, bounded diagnostic instead of
  `error.localizedDescription` when a FirebaseAI call fails.
  `GenerateContentError.internalError`/`.promptImageContentError` recurse into the
  underlying `BackendError` to surface `httpResponseCode` / `message` / `status`
  (previously collapsed to the useless `"GenerateContentError 0"`). The
  `.responseStoppedEarly` / `.promptBlocked` cases log a short, PII-safe form
  (case + reason/blockReason, message capped at 300 chars) rather than dumping the
  full `GenerateContentResponse`. Logging-only — callers still receive the raw,
  unchanged error; no public API change.

#### Package
- Bumped firebase-ios-sdk minimum from `10.0.0` to `11.13.0` (required for Firebase AI)

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

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

### Removed

- `functions/` (TypeScript Cloud Functions backend) and `firebase.json` migrated
  to the consuming-app repo. ARCFirebase is now a pure Swift client package; ship
  and deploy the Functions backend from your app repo. The
  `ARCFirebaseCloudFunctions` Swift client (`CloudFunctionsProviding`) stays in
  this package and remains unchanged.

### Documentation

#### ARCFirebaseCloudFunctions
- `CloudFunctionsProviding` docstring clarifies that consumers ship their own
  Functions backend; this package only provides the Swift client.

- README, GettingStarted.docc, MultiAppSetup.docc, SecurityBestPractices.docc:
  replaced ARC-internal example names (FavRes, FavBook) with generic placeholders
  (MyApp, AppA, AppB). License section clarifies the dual posture (PolyForm NC
  source-available + internal ARC commercial grant + external commercial contact).
- `@unchecked Sendable` rationale comments added to `FirebaseAppCheckProvider`,
  `FirebaseCloudFunctionsProvider`, and `FirebaseAIProvider`.
- `.live` docstrings on `FirebaseAuthProvider`, `FirebaseAnalyticsProvider`,
  `FirebaseStorageProvider`, `FirebaseAIProvider`, `FirebaseCloudFunctionsProvider`,
  and `FirebaseAppCheckProvider` now call out production-only intent and point
  tests toward `create(…)` / mocks.

### Planned

- Integration tests with Firebase emulator
- Additional query methods for FirestoreRepository
- Batch operations support for Persistence module

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [1.0.0] - 2026-01-13

#### Added

##### ARCFirebaseCore
- `FirebaseManager` singleton for Firebase configuration management
- `FirebaseError` enum with comprehensive error types and descriptions
- `Error+Firebase` extension for error conversion

##### ARCFirebaseAuth
- `AuthProviding` protocol for dependency injection
- `FirebaseAuthProvider` class with full authentication support
- `AuthProviderKey` for SwiftUI Environment integration
- `User` model with Firebase user mapping
- Factory methods: `create()` and `live` property

##### ARCFirebaseAnalytics
- `AnalyticsProviding` protocol for dependency injection
- `FirebaseAnalyticsProvider` class for event tracking
- `AnalyticsProviderKey` for SwiftUI Environment integration
- `AnalyticsEvent` and `AnalyticsParameter` predefined constants
- Factory methods: `create()` and `live` property

##### ARCFirebaseCrashlytics
- `CrashlyticsProviding` protocol for dependency injection
- `FirebaseCrashlyticsProvider` class for crash reporting
- `CrashlyticsProviderKey` for SwiftUI Environment integration
- Support for error recording, logging, user context, and custom values
- Factory methods: `create()` and `live` property

##### ARCFirebasePersistence
- `Repository` protocol for generic CRUD operations
- `FirestoreRepository<T>` generic implementation with advanced queries
- `FirestoreDocument` protocol with timestamp helpers
- Support for equality queries, ordering, and limits

##### ARCFirebaseStorage
- `StorageProviding` protocol for dependency injection
- `FirebaseStorageProvider` class for cloud storage operations
- `StorageProviderKey` for SwiftUI Environment integration
- `StorageReference` type-safe path builder with helpers
- Factory methods: `create()` and `live` property

#### Testing
- Comprehensive mock providers for all modules
- 64 unit tests covering all protocols and implementations
- Swift Testing framework integration

#### Documentation
- DocC documentation for all modules
- Comprehensive README with usage examples
- CLAUDE.md with project guidelines

#### Infrastructure
- ARCDevTools integration with SwiftLint and SwiftFormat
- Git hooks for pre-commit and pre-push quality checks
- Swift 6.0 strict concurrency compliance
- Support for iOS 17+, macOS 14+, watchOS 10+, visionOS 1+

---

[1.0.0]: https://github.com/arclabs-studio/ARCFirebase/releases/tag/v1.0.0
