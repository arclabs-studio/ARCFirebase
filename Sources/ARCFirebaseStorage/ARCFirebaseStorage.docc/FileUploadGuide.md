# File Upload Guide

Learn how to upload and manage files with Firebase Storage.

## Overview

This guide covers uploading images, documents, and other files to Firebase Storage using the protocol-based architecture for dependency injection and testability.

## Basic Setup

### Production Setup

```swift
import ARCFirebaseStorage
import ARCFirebaseCore

// Configure Firebase at app launch
FirebaseManager.configure()

// Create the storage provider
let storage = try FirebaseStorageProvider()
// Or use the convenience accessor
let storage = FirebaseStorageProvider.live
```

### Dependency Injection

For better testability, inject the storage provider into your classes:

```swift
class ImageUploader {
    private let storage: any StorageProviding

    init(storage: any StorageProviding) {
        self.storage = storage
    }

    func uploadImage(_ imageData: Data, path: String) async throws -> URL {
        return try await storage.upload(
            data: imageData,
            path: path,
            contentType: "image/jpeg"
        )
    }
}

// Production
let uploader = ImageUploader(storage: FirebaseStorageProvider.live)

// Testing
let uploader = ImageUploader(storage: MockStorageProvider())
```

## Uploading Files

### Upload Image Data

```swift
let storage = FirebaseStorageProvider.live

#if canImport(UIKit)
import UIKit

// Convert UIImage to Data
let image = UIImage(named: "photo")!
let imageData = image.jpegData(compressionQuality: 0.8)!

// Upload
let downloadURL = try await storage.upload(
    data: imageData,
    path: "restaurants/\(restaurantID)/photo.jpg",
    contentType: "image/jpeg"
)

print("Uploaded to: \(downloadURL)")
#endif
```

### Upload from File URL

```swift
let storage = FirebaseStorageProvider.live
let fileURL = URL(fileURLWithPath: "/path/to/document.pdf")

let downloadURL = try await storage.upload(
    fileURL: fileURL,
    path: "documents/\(userID)/resume.pdf"
)
```

## Downloading Files

### Get Download URL

```swift
let storage = FirebaseStorageProvider.live

let url = try await storage.downloadURL(
    path: "restaurants/abc123/photo.jpg"
)

// Use URLSession or AsyncImage to load
AsyncImage(url: url) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

### Download to Memory

For small files only (<10 MB):

```swift
let storage = FirebaseStorageProvider.live

let data = try await storage.download(
    path: "restaurants/abc123/photo.jpg"
)

#if canImport(UIKit)
let image = UIImage(data: data)
#endif
```

## Deleting Files

```swift
let storage = FirebaseStorageProvider.live

try await storage.delete(
    path: "restaurants/abc123/photo.jpg"
)
```

## Storage Paths

### Using StorageReference

```swift
let storage = FirebaseStorageProvider.live

// Restaurant photo
let ref = StorageReference.restaurantPhoto(
    restaurantID: restaurant.id,
    filename: "main-photo.jpg"
)

let url = try await storage.upload(
    data: imageData,
    path: ref.fullPath,
    contentType: "image/jpeg"
)
```

### Custom Paths

```swift
let ref = StorageReference(
    path: "users/\(userID)/profile.jpg"
)
```

## SwiftUI Integration

### Environment Values

Use SwiftUI's environment to pass the storage provider through your view hierarchy:

```swift
import SwiftUI
import ARCFirebaseStorage

@main
struct MyApp: App {
    let storage = FirebaseStorageProvider.live

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.storageProvider, storage)
        }
    }
}
```

### Image Upload View

```swift
struct ImageUploadView: View {
    @Environment(\.storageProvider) var storage
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadedURL: URL?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)

                Button("Upload") {
                    uploadImage()
                }
                .disabled(isUploading)
            }

            if isUploading {
                ProgressView("Uploading...")
            }

            if let url = uploadedURL {
                Text("Uploaded!")
                Text(url.absoluteString)
                    .font(.caption)
            }
        }
    }

    func uploadImage() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }

        isUploading = true

        Task {
            do {
                let url = try await storage.upload(
                    data: imageData,
                    path: "uploads/\(UUID().uuidString).jpg",
                    contentType: "image/jpeg"
                )
                uploadedURL = url
            } catch {
                print("Upload failed: \(error)")
            }
            isUploading = false
        }
    }
}
```

## Best Practices

### Organize Files by User

```swift
// Good structure
"users/{userId}/profile.jpg"
"users/{userId}/documents/resume.pdf"
"restaurants/{restaurantId}/photos/{photoId}.jpg"

// Bad structure (all files mixed together)
"uploads/photo1.jpg"
"uploads/photo2.jpg"
```

### Use Descriptive Filenames

```swift
// Good
let filename = "\(Date().timeIntervalSince1970)-\(restaurant.name).jpg"

// Bad
let filename = "image.jpg"  // Will overwrite previous uploads
```

### Compress Images

```swift
// Compress before upload
let compressedData = image.jpegData(compressionQuality: 0.7)
```

### Handle Large Files

For files >10 MB, use download URL instead of downloading to memory:

```swift
let storage = FirebaseStorageProvider.live

// For large files, get URL and stream download
let url = try await storage.downloadURL(path: path)

// Then use URLSession to download with progress tracking
let (localURL, _) = try await URLSession.shared.download(from: url)
```

### Clean Up Old Files

```swift
let storage = FirebaseStorageProvider.live

// Delete old profile photo before uploading new one
try? await storage.delete(
    path: "users/\(userID)/profile.jpg"
)

// Upload new photo
let url = try await storage.upload(
    data: newImageData,
    path: "users/\(userID)/profile.jpg",
    contentType: "image/jpeg"
)
```

## Security

### Storage Security Rules

Configure in Firebase Console:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null
                        && request.auth.uid == userId;
    }

    // Public read, authenticated write
    match /restaurants/{restaurantId}/photos/{photoId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Testing with Mocks

Create a mock provider for testing:

```swift
actor MockStorageProvider: StorageProviding {
    var uploadedFiles: [String: Data] = [:]
    var mockDownloadURL = URL(string: "https://example.com/file.jpg")!

    func upload(data: Data, path: String, contentType: String) async throws -> URL {
        uploadedFiles[path] = data
        return mockDownloadURL
    }

    func upload(fileURL: URL, path: String) async throws -> URL {
        let data = try Data(contentsOf: fileURL)
        uploadedFiles[path] = data
        return mockDownloadURL
    }

    func downloadURL(path: String) async throws -> URL {
        guard uploadedFiles[path] != nil else {
            throw NSError(domain: "MockStorageError", code: 404)
        }
        return mockDownloadURL
    }

    func download(path: String) async throws -> Data {
        guard let data = uploadedFiles[path] else {
            throw NSError(domain: "MockStorageError", code: 404)
        }
        return data
    }

    func delete(path: String) async throws {
        uploadedFiles.removeValue(forKey: path)
    }
}

// In tests
func testUpload() async throws {
    let mock = MockStorageProvider()
    let uploader = ImageUploader(storage: mock)

    let testData = Data([1, 2, 3, 4])
    let url = try await uploader.uploadImage(testData, path: "test/image.jpg")

    #expect(url == mock.mockDownloadURL)
    let stored = await mock.uploadedFiles["test/image.jpg"]
    #expect(stored == testData)
}
```

## See Also

- ``StorageProviding``
- ``FirebaseStorageProvider``
- ``StorageReference``
- <doc:/ARCFirebaseCore/SecurityBestPractices>
