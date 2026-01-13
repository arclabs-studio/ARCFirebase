import Foundation

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
    /// - Warning: Only use for small files (<10 MB).
    func download(path: String) async throws -> Data

    /// Deletes a file from storage.
    ///
    /// - Parameter path: The storage path.
    /// - Throws: Storage errors.
    func delete(path: String) async throws
}
