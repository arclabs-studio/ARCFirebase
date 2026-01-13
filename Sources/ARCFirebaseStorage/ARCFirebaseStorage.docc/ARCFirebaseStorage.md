# ``ARCFirebaseStorage``

Firebase Storage integration for file uploads and downloads.

## Overview

ARCFirebaseStorage provides a simplified interface to Firebase Storage for uploading images, documents, and other files.

## Key Features

- **File uploads**: Upload from Data or file URLs
- **File downloads**: Get download URLs or data
- **Type-safe paths**: StorageReference for path management
- **Progress tracking**: Monitor upload/download progress

## Topics

### Getting Started

- <doc:FileUploadGuide>

### Storage Manager

- ``StorageManager``

### Upload

- ``StorageManager/upload(data:path:contentType:)``
- ``StorageManager/upload(fileURL:path:)``

### Download

- ``StorageManager/downloadURL(path:)``
- ``StorageManager/download(path:)``

### Delete

- ``StorageManager/delete(path:)``

### Path Management

- ``StorageReference``
