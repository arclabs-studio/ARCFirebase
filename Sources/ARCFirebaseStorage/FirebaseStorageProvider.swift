import Foundation
import FirebaseStorage
import ARCFirebaseCore
import ARCLogger

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
    private let logger = ARCLogger(category: "FirebaseStorage")

    // MARK: - Initialization

    /// Creates a Firebase storage provider.
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init() throws {
        try FirebaseManager.ensureConfigured()
        logger.info("FirebaseStorageProvider initialized")
    }

    // MARK: - StorageProviding Implementation

    public func upload(data: Data, path: String, contentType: String) async throws -> URL {
        logger.info("Uploading to: \(path)")

        do {
            let ref = storage.reference().child(path)
            let metadata = StorageMetadata()
            metadata.contentType = contentType

            let _ = try await ref.putDataAsync(data, metadata: metadata)
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
            let _ = try await ref.putFileAsync(from: fileURL)
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
            let data = try await ref.data(maxSize: 10 * 1024 * 1024) // 10 MB max

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

// MARK: - Convenience

extension FirebaseStorageProvider {

    /// Default live instance for production use.
    public static var live: FirebaseStorageProvider {
        try! FirebaseStorageProvider()
    }
}
