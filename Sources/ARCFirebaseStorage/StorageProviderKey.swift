//
//  StorageProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    /// The storage provider in the environment.
    @Entry public var storageProvider: any StorageProviding = PlaceholderStorageProvider()
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderStorageProvider: StorageProviding, @unchecked Sendable {
    func upload(data _: Data, path _: String, contentType _: String) async throws -> URL {
        placeholderCrash()
    }

    func upload(fileURL _: URL, path _: String) async throws -> URL {
        placeholderCrash()
    }

    func downloadURL(path _: String) async throws -> URL {
        placeholderCrash()
    }

    func download(path _: String) async throws -> Data {
        placeholderCrash()
    }

    func delete(path _: String) async throws {
        placeholderCrash()
    }

    private func placeholderCrash() -> Never {
        fatalError("""
        StorageProvider not configured.
        You must set the storage provider in your app's environment:

            .environment(\\.storageProvider, storageProvider)

        Or use a mock provider for previews/testing:

            .environment(\\.storageProvider, MockStorageProvider())
        """)
    }
}
