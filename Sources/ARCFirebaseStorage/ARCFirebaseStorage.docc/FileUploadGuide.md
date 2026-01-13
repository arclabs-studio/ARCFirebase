# File Upload Guide

Learn how to upload and manage files with Firebase Storage.

## Overview

This guide covers uploading images, documents, and other files to Firebase Storage.

## Basic Setup

```swift
import ARCFirebaseStorage

// Configure at app launch
FirebaseManager.configure()
try StorageManager.shared.configure()
```

## Uploading Files

### Upload Image Data

```swift
#if canImport(UIKit)
import UIKit

// Convert UIImage to Data
let image = UIImage(named: "photo")!
let imageData = image.jpegData(compressionQuality: 0.8)!

// Upload
let downloadURL = try await StorageManager.shared.upload(
    data: imageData,
    path: "restaurants/\(restaurantID)/photo.jpg",
    contentType: "image/jpeg"
)

print("Uploaded to: \(downloadURL)")
#endif
```

### Upload from File URL

```swift
let fileURL = URL(fileURLWithPath: "/path/to/document.pdf")

let downloadURL = try await StorageManager.shared.upload(
    fileURL: fileURL,
    path: "documents/\(userID)/resume.pdf"
)
```

## Downloading Files

### Get Download URL

```swift
let url = try await StorageManager.shared.downloadURL(
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
let data = try await StorageManager.shared.download(
    path: "restaurants/abc123/photo.jpg"
)

#if canImport(UIKit)
let image = UIImage(data: data)
#endif
```

## Deleting Files

```swift
try await StorageManager.shared.delete(
    path: "restaurants/abc123/photo.jpg"
)
```

## Storage Paths

### Using StorageReference

```swift
// Restaurant photo
let ref = StorageReference.restaurantPhoto(
    restaurantID: restaurant.id,
    filename: "main-photo.jpg"
)

let url = try await StorageManager.shared.upload(
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

### Image Upload View

```swift
struct ImageUploadView: View {
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
                let url = try await StorageManager.shared.upload(
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
// For large files, get URL and stream download
let url = try await StorageManager.shared.downloadURL(path: path)

// Then use URLSession to download with progress tracking
let (localURL, _) = try await URLSession.shared.download(from: url)
```

### Clean Up Old Files

```swift
// Delete old profile photo before uploading new one
try? await StorageManager.shared.delete(
    path: "users/\(userID)/profile.jpg"
)

// Upload new photo
let url = try await StorageManager.shared.upload(
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

## See Also

- ``StorageManager``
- ``StorageReference``
- <doc:/ARCFirebaseCore/SecurityBestPractices>
