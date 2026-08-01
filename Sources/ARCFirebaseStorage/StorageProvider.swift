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

// MARK: - StorageProviding Protocol

/// Protocol defining file storage capabilities.
///
/// Use this protocol for dependency injection to make your code testable.
///
/// ## Usage in Production
///
/// ```swift
/// class ImageUploader {
///     private let storage: StorageProviding
///
///     init(storage: StorageProviding) {
///         self.storage = storage
///     }
///
///     func upload(image: Data) async throws -> URL {
///         return try await storage.upload(
///             data: image,
///             path: "images/\(UUID().uuidString).jpg",
///             contentType: "image/jpeg"
///         )
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// actor MockStorageProvider: StorageProviding {
///     var uploadedFiles: [String: Data] = [:]
///     var mockURL = URL(string: "https://example.com/image.jpg")!
///
///     func upload(data: Data, path: String, contentType: String) async throws -> URL {
///         uploadedFiles[path] = data
///         return mockURL
///     }
///
///     func upload(fileURL: URL, path: String) async throws -> URL {
///         return mockURL
///     }
///
///     func downloadURL(path: String) async throws -> URL {
///         return mockURL
///     }
///
///     func download(path: String) async throws -> Data {
///         return uploadedFiles[path] ?? Data()
///     }
///
///     func delete(path: String) async throws {
///         uploadedFiles.removeValue(forKey: path)
///     }
/// }
///
/// func testUploader() async throws {
///     let mock = MockStorageProvider()
///     let uploader = ImageUploader(storage: mock)
///
///     let url = try await uploader.upload(image: testImageData)
///
///     #expect(url == mock.mockURL)
/// }
/// ```
///
/// ## Topics
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
/// ### Implementations
/// - ``FirebaseStorageProvider``
public protocol StorageProviding: Sendable {
    /// Uploads data to storage.
    ///
    /// - Parameters:
    ///   - data: The data to upload.
    ///   - path: The storage path.
    ///   - contentType: The MIME type.
    /// - Returns: The download URL.
    /// - Throws: Storage errors.
    func upload(data: Data, path: String, contentType: String) async throws -> URL

    /// Uploads a file from a local URL.
    ///
    /// - Parameters:
    ///   - fileURL: The local file URL.
    ///   - path: The storage path.
    /// - Returns: The download URL.
    /// - Throws: Storage errors.
    func upload(fileURL: URL, path: String) async throws -> URL

    /// Gets the download URL for a file.
    ///
    /// - Parameter path: The storage path.
    /// - Returns: The download URL.
    /// - Throws: Storage errors.
    func downloadURL(path: String) async throws -> URL

    /// Downloads a file to memory.
    ///
    /// - Parameter path: The storage path.
    /// - Returns: The file data.
    /// - Throws: Storage errors.
    ///
    /// - Warning: Only use for files smaller than ``StorageConfiguration/maxDownloadSize``.
    ///           Default limit is 10 MB. Use ``downloadURL(path:)`` for larger files.
    func download(path: String) async throws -> Data

    /// Deletes a file from storage.
    ///
    /// - Parameter path: The storage path.
    /// - Throws: Storage errors.
    func delete(path: String) async throws
}
