import Testing
import Foundation
@testable import ARCFirebaseStorage

@Suite("FirebaseStorageProvider Tests")
struct FirebaseStorageProviderTests {

    // MARK: - Mock Provider Tests

    @Test("Mock provider uploads data")
    func mockUploadsData() async throws {
        let mock = MockStorageProvider()
        let testData = "Hello, World!".data(using: .utf8)!

        let url = try await mock.upload(
            data: testData,
            path: "test/file.txt",
            contentType: "text/plain"
        )

        #expect(await mock.uploadDataCallCount == 1)
        #expect(url.absoluteString == "https://example.com/file.jpg")
        #expect(await mock.hasFile(at: "test/file.txt"))

        let storedData = await mock.uploadedFiles["test/file.txt"]
        #expect(storedData == testData)
    }

    @Test("Mock provider uploads file from URL")
    func mockUploadsFileFromURL() async throws {
        let mock = MockStorageProvider()

        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("test-\(UUID().uuidString).txt")
        let testData = "Test file content".data(using: .utf8)!
        try testData.write(to: fileURL)

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let url = try await mock.upload(fileURL: fileURL, path: "uploads/file.txt")

        #expect(await mock.uploadFileCallCount == 1)
        #expect(url.absoluteString == "https://example.com/file.jpg")
        #expect(await mock.hasFile(at: "uploads/file.txt"))

        let storedData = await mock.uploadedFiles["uploads/file.txt"]
        #expect(storedData == testData)
    }

    @Test("Mock provider gets download URL")
    func mockGetsDownloadURL() async throws {
        let mock = MockStorageProvider()
        let testData = "test".data(using: .utf8)!

        // Upload first
        _ = try await mock.upload(data: testData, path: "test/file.txt", contentType: "text/plain")

        // Get download URL
        let url = try await mock.downloadURL(path: "test/file.txt")

        #expect(await mock.downloadURLCallCount == 1)
        #expect(url.absoluteString == "https://example.com/file.jpg")
    }

    @Test("Mock provider downloads data")
    func mockDownloadsData() async throws {
        let mock = MockStorageProvider()
        let testData = "Download test".data(using: .utf8)!

        // Upload first
        _ = try await mock.upload(data: testData, path: "downloads/file.txt", contentType: "text/plain")

        // Download
        let downloadedData = try await mock.download(path: "downloads/file.txt")

        #expect(await mock.downloadCallCount == 1)
        #expect(downloadedData == testData)
    }

    @Test("Mock provider deletes files")
    func mockDeletesFiles() async throws {
        let mock = MockStorageProvider()
        let testData = "Delete test".data(using: .utf8)!

        // Upload first
        _ = try await mock.upload(data: testData, path: "temp/file.txt", contentType: "text/plain")
        #expect(await mock.hasFile(at: "temp/file.txt"))

        // Delete
        try await mock.delete(path: "temp/file.txt")

        #expect(await mock.deleteCallCount == 1)
        #expect(await mock.hasFile(at: "temp/file.txt") == false)
    }

    @Test("Mock provider throws error when file not found")
    func mockThrowsErrorWhenFileNotFound() async throws {
        let mock = MockStorageProvider()

        do {
            _ = try await mock.downloadURL(path: "nonexistent/file.txt")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is MockStorageError)
        }

        do {
            _ = try await mock.download(path: "nonexistent/file.txt")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is MockStorageError)
        }

        do {
            try await mock.delete(path: "nonexistent/file.txt")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is MockStorageError)
        }
    }

    @Test("Mock provider throws configured error")
    func mockThrowsConfiguredError() async throws {
        let mock = MockStorageProvider()

        await mock.reset()
        mock.mockError = MockStorageError.uploadFailed

        do {
            _ = try await mock.upload(
                data: Data(),
                path: "test/file.txt",
                contentType: "text/plain"
            )
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is MockStorageError)
        }
    }

    @Test("Mock provider tracks file count")
    func mockTracksFileCount() async throws {
        let mock = MockStorageProvider()

        #expect(await mock.fileCount() == 0)

        _ = try await mock.upload(data: Data(), path: "file1.txt", contentType: "text/plain")
        #expect(await mock.fileCount() == 1)

        _ = try await mock.upload(data: Data(), path: "file2.txt", contentType: "text/plain")
        #expect(await mock.fileCount() == 2)

        try await mock.delete(path: "file1.txt")
        #expect(await mock.fileCount() == 1)
    }

    @Test("Mock reset clears all state")
    func mockResetClearsAllState() async throws {
        let mock = MockStorageProvider()

        // Perform operations
        _ = try await mock.upload(data: Data(), path: "test.txt", contentType: "text/plain")
        _ = try await mock.download(path: "test.txt")

        #expect(await mock.uploadDataCallCount == 1)
        #expect(await mock.downloadCallCount == 1)
        #expect(await mock.fileCount() == 1)

        // Reset
        await mock.reset()

        #expect(await mock.uploadDataCallCount == 0)
        #expect(await mock.downloadCallCount == 0)
        #expect(await mock.fileCount() == 0)
    }

    // MARK: - StorageReference Tests

    @Test("StorageReference initialization with bucket")
    func storageReferenceInitialization() {
        let ref = StorageReference(
            bucket: "test-bucket",
            path: "photos/image.jpg"
        )

        #expect(ref.bucket == "test-bucket")
        #expect(ref.path == "photos/image.jpg")
        #expect(ref.fullPath == "test-bucket/photos/image.jpg")
    }

    @Test("StorageReference initialization without bucket")
    func storageReferenceWithoutBucket() {
        let ref = StorageReference(
            bucket: nil,
            path: "photos/image.jpg"
        )

        #expect(ref.bucket == nil)
        #expect(ref.path == "photos/image.jpg")
        #expect(ref.fullPath == "photos/image.jpg")
    }

    @Test("Restaurant photo reference helper")
    func restaurantPhotoReference() {
        let ref = StorageReference.restaurantPhoto(
            restaurantID: "abc123",
            filename: "photo.jpg"
        )

        #expect(ref.path == "restaurants/abc123/photos/photo.jpg")
    }

    @Test("User profile photo reference helper")
    func userProfilePhotoReference() {
        let ref = StorageReference.userProfilePhoto(userID: "user456")

        #expect(ref.path == "users/user456/profile.jpg")
    }
}
