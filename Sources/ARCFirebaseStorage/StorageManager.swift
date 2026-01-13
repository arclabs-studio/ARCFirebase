import Foundation
import FirebaseStorage
import ARCFirebaseCore
import ARCLogger

/// Manages file uploads and downloads with Firebase Storage.
///
/// `StorageManager` provides a simplified interface to Firebase Storage
/// for uploading images, documents, and other files.
///
/// ## Topics
///
/// ### Configuration
/// - ``configure()``
///
/// ### Upload
/// - ``upload(data:path:contentType:)``
/// - ``upload(fileURL:path:)``
///
/// ### Download
/// - ``downloadURL(path:)``
/// - ``download(path:)``
///
/// ### Delete
/// - ``delete(path:)``
///
/// ### Guide
/// - <doc:FileUploadGuide>
public final class StorageManager {

    // MARK: - Singleton

    /// Shared singleton instance.
    public static let shared = StorageManager()

    // MARK: - Properties

    private let logger = ARCLogger(category: "Storage")
    private let storage = Storage.storage()

    // MARK: - Initialization

    private init() {}

    // MARK: - Configuration

    /// Configures the storage manager.
    ///
    /// Call this after Firebase is configured.
    ///
    /// ```swift
    /// FirebaseManager.configure()
    /// try StorageManager.shared.configure()
    /// ```
    ///
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public func configure() throws {
        try FirebaseManager.shared.ensureConfigured()
        logger.info("StorageManager configured successfully")
    }

    // MARK: - Upload

    /// Uploads data to Firebase Storage.
    ///
    /// ```swift
    /// let imageData = image.jpegData(compressionQuality: 0.8)!
    /// let downloadURL = try await StorageManager.shared.upload(
    ///     data: imageData,
    ///     path: "restaurants/\(restaurantID)/photo.jpg",
    ///     contentType: "image/jpeg"
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - data: The data to upload.
    ///   - path: The storage path (e.g., "restaurants/abc123/photo.jpg").
    ///   - contentType: The MIME type of the data (e.g., "image/jpeg").
    /// - Returns: The download URL for the uploaded file.
    /// - Throws: Firebase Storage errors.
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

    /// Uploads a file from a local URL.
    ///
    /// ```swift
    /// let fileURL = URL(fileURLWithPath: "/path/to/document.pdf")
    /// let downloadURL = try await StorageManager.shared.upload(
    ///     fileURL: fileURL,
    ///     path: "documents/\(userID)/document.pdf"
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - fileURL: The local file URL.
    ///   - path: The storage path.
    /// - Returns: The download URL for the uploaded file.
    /// - Throws: Firebase Storage errors.
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

    // MARK: - Download

    /// Gets the download URL for a file.
    ///
    /// ```swift
    /// let url = try await StorageManager.shared.downloadURL(
    ///     path: "restaurants/abc123/photo.jpg"
    /// )
    /// // Use URLSession to download the file
    /// ```
    ///
    /// - Parameter path: The storage path.
    /// - Returns: The download URL.
    /// - Throws: Firebase Storage errors.
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

    /// Downloads a file to memory.
    ///
    /// ```swift
    /// let data = try await StorageManager.shared.download(
    ///     path: "restaurants/abc123/photo.jpg"
    /// )
    /// let image = UIImage(data: data)
    /// ```
    ///
    /// - Parameter path: The storage path.
    /// - Returns: The file data.
    /// - Throws: Firebase Storage errors.
    ///
    /// - Warning: Only use for small files (<10 MB). For larger files, use ``downloadURL(path:)``
    ///            and download with URLSession.
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

    // MARK: - Delete

    /// Deletes a file from Firebase Storage.
    ///
    /// ```swift
    /// try await StorageManager.shared.delete(
    ///     path: "restaurants/abc123/photo.jpg"
    /// )
    /// ```
    ///
    /// - Parameter path: The storage path.
    /// - Throws: Firebase Storage errors.
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
