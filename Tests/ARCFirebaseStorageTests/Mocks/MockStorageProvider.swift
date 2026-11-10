import Foundation
import os
@testable import ARCFirebaseStorage

/// Mock storage provider for testing.
final class MockStorageProvider: StorageProviding {
    private struct State {
        var uploadedFiles: [String: Data] = [:]
        var mockError: Error?
        var uploadDataCallCount: Int = 0
        var uploadFileCallCount: Int = 0
        var downloadURLCallCount: Int = 0
        var downloadCallCount: Int = 0
        var deleteCallCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var uploadedFiles: [String: Data] {
        state.withLock { $0.uploadedFiles }
    }

    let mockDownloadURL: URL = {
        guard let url = URL(string: "https://example.com/file.jpg") else {
            preconditionFailure("MockStorageProvider: invalid mock URL constant")
        }
        return url
    }()

    var mockError: Error? {
        get { state.withLock { $0.mockError } }
        set { state.withLock { $0.mockError = newValue } }
    }

    var uploadDataCallCount: Int {
        state.withLock { $0.uploadDataCallCount }
    }

    var uploadFileCallCount: Int {
        state.withLock { $0.uploadFileCallCount }
    }

    var downloadURLCallCount: Int {
        state.withLock { $0.downloadURLCallCount }
    }

    var downloadCallCount: Int {
        state.withLock { $0.downloadCallCount }
    }

    var deleteCallCount: Int {
        state.withLock { $0.deleteCallCount }
    }

    // MARK: - StorageProviding Implementation

    func upload(data: Data, path: String, contentType _: String) async throws -> URL {
        state.withLock { $0.uploadDataCallCount += 1 }

        if let error = mockError {
            throw error
        }

        state.withLock { $0.uploadedFiles[path] = data }
        return mockDownloadURL
    }

    func upload(fileURL: URL, path: String) async throws -> URL {
        state.withLock { $0.uploadFileCallCount += 1 }

        if let error = mockError {
            throw error
        }

        // Read file data and store it
        let data = try Data(contentsOf: fileURL)
        state.withLock { $0.uploadedFiles[path] = data }
        return mockDownloadURL
    }

    func downloadURL(path: String) async throws -> URL {
        state.withLock { $0.downloadURLCallCount += 1 }

        if let error = mockError {
            throw error
        }

        guard uploadedFiles[path] != nil else {
            throw MockStorageError.fileNotFound
        }

        return mockDownloadURL
    }

    func download(path: String) async throws -> Data {
        state.withLock { $0.downloadCallCount += 1 }

        if let error = mockError {
            throw error
        }

        guard let data = uploadedFiles[path] else {
            throw MockStorageError.fileNotFound
        }

        return data
    }

    func delete(path: String) async throws {
        state.withLock { $0.deleteCallCount += 1 }

        if let error = mockError {
            throw error
        }

        guard uploadedFiles[path] != nil else {
            throw MockStorageError.fileNotFound
        }

        state.withLock { _ = $0.uploadedFiles.removeValue(forKey: path) }
    }

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.uploadedFiles.removeAll() }
        state.withLock { $0.mockError = nil }
        state.withLock { $0.uploadDataCallCount = 0 }
        state.withLock { $0.uploadFileCallCount = 0 }
        state.withLock { $0.downloadURLCallCount = 0 }
        state.withLock { $0.downloadCallCount = 0 }
        state.withLock { $0.deleteCallCount = 0 }
    }

    func hasFile(at path: String) -> Bool {
        uploadedFiles[path] != nil
    }

    func fileCount() -> Int {
        uploadedFiles.count
    }

    func setMockError(_ error: Error?) {
        state.withLock { $0.mockError = error }
    }
}

// MARK: - Mock Errors

enum MockStorageError: Error {
    case fileNotFound
    case uploadFailed
    case downloadFailed
}
