//
//  AnalyticsProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import SwiftUI

extension EnvironmentValues {
    // The analytics provider in the environment.
    @Entry public var analyticsProvider: any AnalyticsProviding = PlaceholderAnalyticsProvider()
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
