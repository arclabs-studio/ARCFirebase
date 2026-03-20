//
//  CloudFunctionsProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import SwiftUI

/// Placeholder provider that crashes with a helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderCloudFunctionsProvider: CloudFunctionsProviding, @unchecked Sendable {
    func call<Response: Decodable & Sendable>(_: String, data _: some Encodable & Sendable,
                                              timeout _: TimeInterval?) async throws -> Response {
        placeholderCrash()
    }

    func call<Response: Decodable & Sendable>(_: String, timeout _: TimeInterval?) async throws -> Response {
        placeholderCrash()
    }

    func callVoid(_: String, data _: some Encodable & Sendable, timeout _: TimeInterval?) async throws {
        placeholderCrash()
    }

    func isAvailable() async -> Bool {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError("""
        CloudFunctionsProvider not configured.
        You must set the Cloud Functions provider in your app's environment:

            .environment(\\.cloudFunctionsProvider, cloudFunctionsProvider)

        Or use a mock provider for previews/testing:

            .environment(\\.cloudFunctionsProvider, MockCloudFunctionsProvider())
        """)
    }
}

extension EnvironmentValues {
    /// The Cloud Functions provider in the environment.
    @Entry public var cloudFunctionsProvider: any CloudFunctionsProviding = PlaceholderCloudFunctionsProvider()
}
