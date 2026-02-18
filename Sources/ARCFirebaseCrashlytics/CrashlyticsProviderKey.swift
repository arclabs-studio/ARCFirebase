//
//  CrashlyticsProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

/// SwiftUI Environment key for crashlytics provider.
///
/// This allows passing the crashlytics provider through the SwiftUI environment:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let crashlytics: any CrashlyticsProviding
///
///     init() {
///         do {
///             crashlytics = try FirebaseCrashlyticsProvider.create()
///         } catch {
///             fatalError("Firebase not configured: \(error)")
///         }
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.crashlyticsProvider, crashlytics)
///         }
///     }
/// }
///
/// struct MyView: View {
///     @Environment(\.crashlyticsProvider) var crashlytics
///
///     func handleError(_ error: Error) {
///         crashlytics.record(error: error)
///     }
/// }
/// ```
///
/// - Important: You must explicitly set `.environment(\.crashlyticsProvider, provider)` in your app.
///   The default value will crash if accessed without setting a provider first.
public struct CrashlyticsProviderKey: EnvironmentKey {
    public static let defaultValue: any CrashlyticsProviding = PlaceholderCrashlyticsProvider()
}

extension EnvironmentValues {
    /// The crashlytics provider in the environment.
    public var crashlyticsProvider: any CrashlyticsProviding {
        get { self[CrashlyticsProviderKey.self] }
        set { self[CrashlyticsProviderKey.self] = newValue }
    }
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderCrashlyticsProvider: CrashlyticsProviding {
    func record(error _: Error) {
        placeholderCrash()
    }

    func recordNonFatal(error _: Error) {
        placeholderCrash()
    }

    func log(_: String) {
        placeholderCrash()
    }

    func setUserID(_: String) {
        placeholderCrash()
    }

    func clearUserID() {
        placeholderCrash()
    }

    func setCustomValue(_: any Sendable, forKey _: String) {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError(
            """
            CrashlyticsProvider not configured.
            You must set the crashlytics provider in your app's environment:

                .environment(\\.crashlyticsProvider, crashlyticsProvider)

            Or use a mock provider for previews/testing:

                .environment(\\.crashlyticsProvider, MockCrashlyticsProvider())
            """
        )
    }
}
