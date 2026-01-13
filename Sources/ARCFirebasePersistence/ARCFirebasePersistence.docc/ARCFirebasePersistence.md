# ``ARCFirebasePersistence``

Firestore database integration with type-safe repository pattern.

## Overview

ARCFirebasePersistence provides a generic, type-safe interface to Firestore using the Repository pattern, making database operations simple and testable.

## Key Features

- **Repository pattern**: Clean separation of data access
- **Type-safe**: Generic repositories with Codable support
- **Query support**: Advanced Firestore queries
- **Async/await**: Modern concurrency throughout

## Topics

### Getting Started

- <doc:FirestorePatterns>

### Repository

- ``Repository``
- ``FirestoreRepository``

### CRUD Operations

- ``Repository/fetch(id:)``
- ``Repository/fetchAll()``
- ``Repository/save(_:)``
- ``Repository/update(_:)``
- ``Repository/delete(id:)``

### Models

- ``FirestoreDocument``
