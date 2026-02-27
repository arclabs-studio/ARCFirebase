//
//  StorageConfigurationTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import Foundation
import Testing
@testable import ARCFirebaseStorage

@Suite("StorageConfiguration Tests") struct StorageConfigurationTests {
    // MARK: - Default Configuration

    @Test("Default preset has 10 MB download limit") func defaultPreset() {
        // Given / When
        let config = StorageConfiguration.default

        // Then
        #expect(config.maxDownloadSize == 10 * 1024 * 1024)
    }

    @Test("largeFiles preset has 50 MB download limit") func largeFilesPreset() {
        // Given / When
        let config = StorageConfiguration.largeFiles

        // Then
        #expect(config.maxDownloadSize == 50 * 1024 * 1024)
    }

    // MARK: - Custom Configuration

    @Test("Custom init stores provided maxDownloadSize") func customInit() {
        // Given
        let customSize: Int64 = 25 * 1024 * 1024 // 25 MB

        // When
        let config = makeSUT(maxDownloadSize: customSize)

        // Then
        #expect(config.maxDownloadSize == customSize)
    }

    @Test("Default parameter in init equals 10 MB") func defaultInitParameter() {
        // Given / When
        let config = makeSUT()

        // Then
        #expect(config.maxDownloadSize == 10 * 1024 * 1024)
    }

    @Test("largeFiles limit is five times the default limit") func largeFilesIsMultipleOfDefault() {
        // Given
        let defaultLimit = StorageConfiguration.default.maxDownloadSize
        let largeLimit = StorageConfiguration.largeFiles.maxDownloadSize

        // Then
        #expect(largeLimit == defaultLimit * 5)
    }

    // MARK: - Helpers

    private func makeSUT(maxDownloadSize: Int64 = 10 * 1024 * 1024) -> StorageConfiguration {
        StorageConfiguration(maxDownloadSize: maxDownloadSize)
    }
}
