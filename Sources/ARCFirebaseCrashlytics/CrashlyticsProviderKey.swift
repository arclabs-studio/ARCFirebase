//
//  CrashlyticsProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

extension EnvironmentValues {
    // The crashlytics provider in the environment.
    @Entry public var crashlyticsProvider: any CrashlyticsProviding = PlaceholderCrashlyticsProvider()
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderCrashlyticsProvider: CrashlyticsProviding, @unchecked Sendable {
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
