//
//  MockStorageProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseStorage
import Foundation

// MARK: - MockStorageProvider

/// A mock implementation of `StorageProviding` for SwiftUI previews and testing.
///
/// This provider simulates file storage in memory without connecting to Firebase Storage,
/// making it perfect for:
/// - SwiftUI previews
/// - Unit testing
/// - Development without Firebase configuration
///
/// ## Example Usage
///
/// ```swift
/// let mockStorage = MockStorageProvider()
///
/// // Upload data
/// let url = try await mockStorage.upload(
///     data: imageData,
///     path: "images/photo.jpg",
///     contentType: "image/jpeg"
/// )
///
/// // Verify upload
/// #expect(mockStorage.storedFiles["images/photo.jpg"] != nil)
/// ```
actor MockStorageProvider: StorageProviding {
    // MARK: Storage

    /// In-memory storage for uploaded files.
    private(set) var storedFiles: [String: Data] = [:]

    /// Base URL for mock download URLs.
    private let baseURL = URL(string: "https://mock.storage.arclabs.studio")!

    // MARK: Call Tracking

    /// Number of upload operations performed.
    private(set) var uploadCount = 0

    /// Number of download operations performed.
    private(set) var downloadCount = 0

    /// Number of delete operations performed.
    private(set) var deleteCount = 0

    // MARK: Mock Configuration

    /// Error to throw on upload. Set to `nil` for success.
    var uploadError: Error?

    /// Error to throw on download. Set to `nil` for success.
    var downloadError: Error?

    /// Simulated delay in seconds for async operations.
    var simulatedDelay: TimeInterval = 0.3

    // MARK: Initialization

    init() {}

    // MARK: StorageProviding Implementation

    func upload(data: Data, path: String, contentType _: String) async throws -> URL {
        uploadCount += 1

        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = uploadError {
            throw error
        }

        // Store in memory
        storedFiles[path] = data

        #if DEBUG
        print("[MockStorage] Uploaded \(data.count) bytes to \(path)")
        #endif

        return baseURL.appendingPathComponent(path)
    }

    func upload(fileURL: URL, path: String) async throws -> URL {
        uploadCount += 1

        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = uploadError {
            throw error
        }

        // Read file and store
        let data = try Data(contentsOf: fileURL)
        storedFiles[path] = data

        return baseURL.appendingPathComponent(path)
    }

    func downloadURL(path: String) async throws -> URL {
        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = downloadError {
            throw error
        }

        return baseURL.appendingPathComponent(path)
    }

    func download(path: String) async throws -> Data {
        downloadCount += 1

        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = downloadError {
            throw error
        }

        guard let data = storedFiles[path] else {
            throw MockStorageError.fileNotFound(path)
        }

        return data
    }

    func delete(path: String) async throws {
        deleteCount += 1

        // Simulate network delay
        try await Task.sleep(for: .seconds(simulatedDelay))

        storedFiles.removeValue(forKey: path)

        #if DEBUG
        print("[MockStorage] Deleted file at \(path)")
        #endif
    }

    // MARK: Testing Helpers

    /// Clears all stored files.
    func reset() {
        storedFiles.removeAll()
        uploadCount = 0
        downloadCount = 0
        deleteCount = 0
    }

    /// Pre-populates storage with test data.
    func seedFile(path: String, data: Data) {
        storedFiles[path] = data
    }
}

// MARK: - MockStorageError

/// Errors thrown by MockStorageProvider.
enum MockStorageError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case let .fileNotFound(path):
            "File not found at path: \(path)"
        }
    }
}

// MARK: - Convenience Initializers

extension MockStorageProvider {
    /// Creates a shared mock provider for previews.
    static let preview = MockStorageProvider()
}
