import Foundation
@testable import ARCFirebaseStorage

/// Mock storage provider for testing.
final class MockStorageProvider: StorageProviding, @unchecked Sendable {
    // MARK: - Mock State

    private(set) var uploadedFiles: [String: Data] = [:]
    var mockDownloadURL: URL = {
        guard let url = URL(string: "https://example.com/file.jpg") else {
            preconditionFailure("MockStorageProvider: invalid mock URL constant")
        }
        return url
    }()

    var mockError: Error?
    private(set) var uploadDataCallCount = 0
    private(set) var uploadFileCallCount = 0
    private(set) var downloadURLCallCount = 0
    private(set) var downloadCallCount = 0
    private(set) var deleteCallCount = 0

    // MARK: - StorageProviding Implementation

    func upload(data: Data, path: String, contentType _: String) async throws -> URL {
        uploadDataCallCount += 1

        if let error = mockError {
            throw error
        }

        uploadedFiles[path] = data
        return mockDownloadURL
    }

    func upload(fileURL: URL, path: String) async throws -> URL {
        uploadFileCallCount += 1

        if let error = mockError {
            throw error
        }

        // Read file data and store it
        let data = try Data(contentsOf: fileURL)
        uploadedFiles[path] = data
        return mockDownloadURL
    }

    func downloadURL(path: String) async throws -> URL {
        downloadURLCallCount += 1

        if let error = mockError {
            throw error
        }

        guard uploadedFiles[path] != nil else {
            throw MockStorageError.fileNotFound
        }

        return mockDownloadURL
    }

    func download(path: String) async throws -> Data {
        downloadCallCount += 1

        if let error = mockError {
            throw error
        }

        guard let data = uploadedFiles[path] else {
            throw MockStorageError.fileNotFound
        }

        return data
    }

    func delete(path: String) async throws {
        deleteCallCount += 1

        if let error = mockError {
            throw error
        }

        guard uploadedFiles[path] != nil else {
            throw MockStorageError.fileNotFound
        }

        uploadedFiles.removeValue(forKey: path)
    }

    // MARK: - Test Helpers

    func reset() {
        uploadedFiles.removeAll()
        mockError = nil
        uploadDataCallCount = 0
        uploadFileCallCount = 0
        downloadURLCallCount = 0
        downloadCallCount = 0
        deleteCallCount = 0
    }

    func hasFile(at path: String) -> Bool {
        uploadedFiles[path] != nil
    }

    func fileCount() -> Int {
        uploadedFiles.count
    }

    func setMockError(_ error: Error?) {
        mockError = error
    }
}

// MARK: - Mock Errors

enum MockStorageError: Error {
    case fileNotFound
    case uploadFailed
    case downloadFailed
}
