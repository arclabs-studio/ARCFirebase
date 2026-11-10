//
//  AppProviders.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAI
import ARCFirebaseAnalytics
import ARCFirebaseAuth
import ARCFirebaseCrashlytics
import ARCFirebaseFeatureFlags
import ARCFirebaseStorage

// MARK: - AppProviders

/// The set of providers the example app injects into the SwiftUI Environment.
struct AppProviders {
    let auth: any AuthProviding
    let analytics: any AnalyticsProviding
    let storage: any StorageProviding
    let crashlytics: any CrashlyticsProviding
    let ai: any AIProviding
    let featureFlags: any FeatureFlagProviding

    /// Indicates if running in demo mode (without Firebase).
    let isDemoMode: Bool

    /// Mock providers used when Firebase is not configured or fails to start.
    @MainActor static func demo() -> AppProviders {
        AppProviders(auth: MockAuthProvider.unauthenticated,
                     analytics: MockAnalyticsProvider(),
                     storage: MockStorageProvider(),
                     crashlytics: MockCrashlyticsProvider(),
                     ai: MockAIProvider(),
                     featureFlags: MockFeatureFlagProvider(),
                     isDemoMode: true)
    }
}
