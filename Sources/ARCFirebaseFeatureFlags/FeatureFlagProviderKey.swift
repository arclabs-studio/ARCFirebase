//
//  FeatureFlagProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    /// The feature flag provider in the environment.
    @Entry public var featureFlagProvider: any FeatureFlagProviding = PlaceholderFeatureFlagProvider()
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderFeatureFlagProvider: FeatureFlagProviding, @unchecked Sendable {
    func fetchAndActivate() async throws {
        placeholderCrash()
    }

    func setDefaults(_: [String: any Sendable]) {
        placeholderCrash()
    }

    func bool(forKey _: String, defaultValue _: Bool) -> Bool {
        placeholderCrash()
    }

    func string(forKey _: String, defaultValue _: String) -> String {
        placeholderCrash()
    }

    func int(forKey _: String, defaultValue _: Int) -> Int {
        placeholderCrash()
    }

    func double(forKey _: String, defaultValue _: Double) -> Double {
        placeholderCrash()
    }

    func data(forKey _: String, defaultValue _: Data) -> Data {
        placeholderCrash()
    }

    func configUpdates() -> AsyncStream<Void> {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError("""
        FeatureFlagProvider not configured.
        You must set the feature flag provider in your app's environment:

            .environment(\\.featureFlagProvider, featureFlagProvider)

        Or use a mock provider for previews/testing:

            .environment(\\.featureFlagProvider, MockFeatureFlagProvider())
        """)
    }
}
