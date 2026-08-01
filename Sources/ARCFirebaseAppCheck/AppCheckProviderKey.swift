//
//  AppCheckProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import SwiftUI

/// Placeholder provider that crashes with a helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderAppCheckProvider: AppCheckProviding, @unchecked Sendable {
    var isConfigured: Bool {
        placeholderCrash()
    }

    func configure() throws {
        placeholderCrash()
    }

    func getLimitedUseToken() async throws -> String {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError("""
        AppCheckProvider not configured.
        You must set the App Check provider in your app's environment:

            .environment(\\.appCheckProvider, appCheckProvider)

        Or use a mock provider for previews/testing:

            .environment(\\.appCheckProvider, MockAppCheckProvider())
        """)
    }
}

extension EnvironmentValues {
    /// The App Check provider in the environment.
    @Entry public var appCheckProvider: any AppCheckProviding = PlaceholderAppCheckProvider()
}
