//
//  PreviewHelpers.swift
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
import SwiftUI

// MARK: - Preview Environment Helpers

/// Container for all mock providers used in SwiftUI previews.
///
/// This struct provides a convenient way to inject all mock dependencies
/// at once using the `.previewEnvironment()` modifier.
///
/// ## Example Usage
///
/// ```swift
/// #Preview {
///     MyView()
///         .previewEnvironment()
/// }
/// ```
enum PreviewEnvironment {
    // MARK: Mock Providers

    /// Mock authentication provider for previews.
    @MainActor static let authProvider = MockAuthProvider.authenticated

    /// Mock analytics provider for previews.
    static let analyticsProvider = MockAnalyticsProvider.preview

    /// Mock storage provider for previews.
    static let storageProvider = MockStorageProvider.preview

    /// Mock crashlytics provider for previews.
    static let crashlyticsProvider = MockCrashlyticsProvider.preview

    /// Mock AI provider for previews.
    static let aiProvider = MockAIProvider.preview

    /// Mock feature flag provider for previews.
    static let featureFlagProvider = MockFeatureFlagProvider.preview
}

// MARK: - View Extension for Preview Environment

extension View {
    /// Applies all mock providers for SwiftUI previews.
    ///
    /// This modifier injects mock implementations of all ARCFirebase providers,
    /// allowing views to render in previews without Firebase configuration.
    ///
    /// ## Example
    ///
    /// ```swift
    /// #Preview("Home View") {
    ///     HomeView()
    ///         .previewEnvironment()
    /// }
    ///
    /// #Preview("Home View - Dark Mode") {
    ///     HomeView()
    ///         .previewEnvironment()
    ///         .preferredColorScheme(.dark)
    /// }
    /// ```
    @MainActor func previewEnvironment() -> some View {
        environment(\.authProvider, PreviewEnvironment.authProvider)
            .environment(\.analyticsProvider, PreviewEnvironment.analyticsProvider)
            .environment(\.storageProvider, PreviewEnvironment.storageProvider)
            .environment(\.crashlyticsProvider, PreviewEnvironment.crashlyticsProvider)
            .environment(\.aiProvider, PreviewEnvironment.aiProvider)
            .environment(\.featureFlagProvider, PreviewEnvironment.featureFlagProvider)
    }
}

// MARK: - Sample Data for Previews

/// Sample data for use in SwiftUI previews.
///
/// Provides realistic mock data for all models used in the demo app.
enum SampleData {
    /// Sample items for Firestore demos.
    static let items: [Item] = [Item(id: "item-1",
                                     title: "Learn SwiftUI",
                                     description: "Complete the SwiftUI tutorial and build a sample app",
                                     createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
                                     updatedAt: Date().addingTimeInterval(-86400), // 1 day ago
                                     userId: "mock-user-123"),
                                Item(id: "item-2",
                                     title: "Integrate Firebase",
                                     description: "Set up Firebase Auth, Firestore, and Analytics",
                                     createdAt: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                                     updatedAt: Date().addingTimeInterval(-3600), // 1 hour ago
                                     userId: "mock-user-123"),
                                Item(id: "item-3",
                                     title: "Write Unit Tests",
                                     description: "Add comprehensive tests for ViewModels and UseCases",
                                     createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                                     updatedAt: Date(), // now
                                     userId: "mock-user-123")]

    /// A single sample item.
    static var singleItem: Item {
        items.first!
    }
}
