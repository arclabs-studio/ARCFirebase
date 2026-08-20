//
//  CloudFunctionsConfiguration.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-03-20.
//

import Foundation

/// Configuration options for the Cloud Functions provider.
///
/// Use a preset or create a custom configuration:
///
/// ```swift
/// // Use us-central1 (default)
/// let provider = try FirebaseCloudFunctionsProvider(configuration: .default)
///
/// // Use europe-west1
/// let provider = try FirebaseCloudFunctionsProvider(configuration: .europe)
///
/// // Custom region and timeout
/// let config = CloudFunctionsConfiguration(region: "asia-northeast1", defaultTimeout: 30)
/// let provider = try FirebaseCloudFunctionsProvider(configuration: config)
/// ```
public struct CloudFunctionsConfiguration: Sendable {
    /// The Firebase region hosting the Cloud Functions.
    ///
    /// Common values: `"us-central1"`, `"europe-west1"`, `"asia-northeast1"`.
    public let region: String

    /// The default timeout for function calls, in seconds.
    ///
    /// Individual calls can override this with the `timeout` parameter.
    public let defaultTimeout: TimeInterval

    /// Creates a custom Cloud Functions configuration.
    ///
    /// - Parameters:
    ///   - region: The Firebase region. Defaults to `"us-central1"`.
    ///   - defaultTimeout: The default call timeout in seconds. Defaults to `60`.
    public init(region: String = "us-central1", defaultTimeout: TimeInterval = 60) {
        self.region = region
        self.defaultTimeout = defaultTimeout
    }

    /// Default configuration using `us-central1` region with a 60-second timeout.
    public static let `default` = CloudFunctionsConfiguration()

    /// Europe configuration using `europe-west1` region with a 60-second timeout.
    public static let europe = CloudFunctionsConfiguration(region: "europe-west1")
}
