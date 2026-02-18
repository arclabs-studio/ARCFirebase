//
//  AnalyticsProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import SwiftUI

/// SwiftUI Environment key for analytics provider.
///
/// - Important: You must explicitly set `.environment(\.analyticsProvider, provider)` in your app.
///   The default value will crash if accessed without setting a provider first.
public struct AnalyticsProviderKey: EnvironmentKey {
    public static let defaultValue: any AnalyticsProviding = PlaceholderAnalyticsProvider()
}

extension EnvironmentValues {
    /// The analytics provider in the environment.
    public var analyticsProvider: any AnalyticsProviding {
        get { self[AnalyticsProviderKey.self] }
        set { self[AnalyticsProviderKey.self] = newValue }
    }
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderAnalyticsProvider: AnalyticsProviding, @unchecked Sendable {
    func logEvent(_: String, parameters _: [String: any Sendable]?) {
        placeholderCrash()
    }

    func logScreenView(_: String, screenClass _: String?) {
        placeholderCrash()
    }

    func setUserProperty(_: String, value _: String?) {
        placeholderCrash()
    }

    func setUserID(_: String?) {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError(
            """
            AnalyticsProvider not configured.
            You must set the analytics provider in your app's environment:

                .environment(\\.analyticsProvider, analyticsProvider)

            Or use a mock provider for previews/testing:

                .environment(\\.analyticsProvider, MockAnalyticsProvider())
            """
        )
    }
}
