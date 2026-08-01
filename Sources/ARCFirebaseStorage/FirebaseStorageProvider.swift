//
//  FirebaseStorageProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseStorage
import Foundation

/// Firebase implementation of ``StorageProviding``.
///
/// This is the production storage provider that uses Firebase Storage.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance
/// let storage = try FirebaseStorageProvider()
///
/// // Or use the convenience default
/// let storage = FirebaseStorageProvider.live
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init()``
/// - ``live``
public final class FirebaseStorageProvider: StorageProviding, @unchecked Sendable {
    // MARK: - Properties

    private let storage = Storage.storage()
    private let logger = ARCLogger(subsystem: ARCFirebaseLogSubsystem.current, category: "FirebaseStorage")
    private let configuration: StorageConfiguration

    // MARK: - Initialization

    /// Creates a Firebase storage provider with default configuration.
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init() throws {
        try FirebaseManager.ensureConfigured()
        configuration = .default
        logger.info("FirebaseStorageProvider initialized with default configuration")
    }

    /// Creates a Firebase storage provider with custom configuration.
    ///
    /// - Parameter configuration: The storage configuration to use.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Allow larger downloads
    /// let config = StorageConfiguration(maxDownloadSize: 50 * 1024 * 1024)
    /// let storage = try FirebaseStorageProvider(configuration: config)
    /// ```
    public init(configuration: StorageConfiguration) throws {
        try FirebaseManager.ensureConfigured()
        self.configuration = configuration
        logger.info("FirebaseStorageProvider initialized with maxDownloadSize: \(configuration.maxDownloadSize) bytes")
    }

    // MARK: - StorageProviding Implementation

    public func upload(data: Data, path: String, contentType: String) async throws -> URL {
        logger.info("Uploading to: \(path)")

        do {
            let ref = storage.reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = contentType

            _ = try await ref.putDataAsync(data, metadata: metadata)
            let downloadURL = try await ref.downloadURL()

            logger.info("Upload successful: \(downloadURL)")
            return downloadURL
        } catch {
            logger.error("Upload failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func upload(fileURL: URL, path: String) async throws -> URL {
        logger.info("Uploading file to: \(path)")

        do {
            let ref = storage.reference().child(path)
            _ = try await ref.putFileAsync(from: fileURL)
            let downloadURL = try await ref.downloadURL()

            logger.info("File upload successful: \(downloadURL)")
            return downloadURL
        } catch {
            logger.error("File upload failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func downloadURL(path: String) async throws -> URL {
        logger.debug("Getting download URL for: \(path)")

        do {
            let ref = storage.reference().child(path)
            let url = try await ref.downloadURL()

            logger.debug("Got download URL: \(url)")
            return url
        } catch {
            logger.error("Failed to get download URL: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func download(path: String) async throws -> Data {
        logger.debug("Downloading: \(path)")

        do {
            let ref = storage.reference().child(path)
            let data = try await ref.data(maxSize: configuration.maxDownloadSize)

            logger.debug("Download successful: \(data.count) bytes")
            return data
        } catch {
            logger.error("Download failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }

    public func delete(path: String) async throws {
        logger.info("Deleting: \(path)")

        do {
            let ref = storage.reference().child(path)
            try await ref.delete()

            logger.info("Delete successful: \(path)")
        } catch {
            logger.error("Delete failed: \(error.localizedDescription)")
            throw error.asFirebaseError()
        }
    }
}

// MARK: - Factory Methods

extension FirebaseStorageProvider {
    /// Creates a new instance with explicit error handling.
    ///
    /// Use this method when you want to handle initialization errors:
    ///
    /// ```swift
    /// do {
    ///     let storage = try FirebaseStorageProvider.create()
    /// } catch {
    ///     // Handle configuration error
    /// }
    /// ```
    ///
    /// - Returns: A configured ``FirebaseStorageProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create() throws -> FirebaseStorageProvider {
        try FirebaseStorageProvider()
    }

    /// Default live instance for production use.
    ///
    /// - Important: Production-only. Calls `fatalError` if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first. Tests should use
    ///              ``create()`` (throws) or a mock conforming to ``StorageProviding``
    ///              to avoid the trap.
    public static var live: FirebaseStorageProvider {
        do {
            return try create()
        } catch {
            fatalError("""
            FirebaseStorageProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(error.localizedDescription)
            """)
        }
    }
}
