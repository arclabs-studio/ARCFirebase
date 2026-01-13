# ``ARCFirebaseStorage``

Firebase Storage integration for file uploads and downloads.

## Overview

ARCFirebaseStorage provides a simplified interface to Firebase Storage for uploading images, documents, and other files.

The module follows a protocol-based architecture for testability and flexibility, allowing you to easily swap implementations or use mocks in tests.

## Key Features

- **Protocol-based design**: Use `StorageProviding` for dependency injection
- **File uploads**: Upload from Data or file URLs
- **File downloads**: Get download URLs or data
- **Type-safe paths**: StorageReference for path management
- **Actor-based**: Thread-safe with Swift concurrency
- **SwiftUI integration**: Environment values support
- **Logging**: ARCLogger integration for debugging

## Topics

### Getting Started

- <doc:FileUploadGuide>

### Protocols

- ``StorageProviding``

### Implementations

- ``FirebaseStorageProvider``

### SwiftUI Integration

- ``StorageProviderKey``

### Upload

- ``StorageProviding/upload(data:path:contentType:)``
- ``StorageProviding/upload(fileURL:path:)``

### Download

- ``StorageProviding/downloadURL(path:)``
- ``StorageProviding/download(path:)``

### Delete

- ``StorageProviding/delete(path:)``

### Path Management

- ``StorageReference``
