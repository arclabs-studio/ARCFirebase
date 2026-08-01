//
//  StorageConfiguration.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import Foundation

// MARK: - StorageConfiguration

/// Configuration options for storage providers.
///
/// Use this struct to customize storage behavior such as size limits.
///
/// ## Usage
///
/// ```swift
/// // Create custom configuration
/// let config = StorageConfiguration(
///     maxDownloadSize: 50 * 1024 * 1024  // 50 MB
/// )
///
/// // Use with provider
/// let storage = try FirebaseStorageProvider(configuration: config)
/// ```
///
/// ## Topics
///
/// ### Properties
/// - ``maxDownloadSize``
///
/// ### Presets
/// - ``default``
/// - ``largeFiles``
public struct StorageConfiguration: Sendable {
    /// Maximum size in bytes for in-memory downloads.
    ///
    /// Files larger than this limit will fail when using ``StorageProviding/download(path:)``.
    /// For larger files, use ``StorageProviding/downloadURL(path:)`` and stream the data.
    ///
    /// Default: 10 MB (10,485,760 bytes)
    public let maxDownloadSize: Int64

    /// Creates a storage configuration with custom settings.
    ///
    /// - Parameter maxDownloadSize: Maximum download size in bytes. Default is 10 MB.
    public init(maxDownloadSize: Int64 = 10 * 1024 * 1024) {
        self.maxDownloadSize = maxDownloadSize
    }

    /// Default configuration with 10 MB download limit.
    public static let `default` = StorageConfiguration()

    /// Configuration for large files with 50 MB download limit.
    public static let largeFiles = StorageConfiguration(maxDownloadSize: 50 * 1024 * 1024)
}
