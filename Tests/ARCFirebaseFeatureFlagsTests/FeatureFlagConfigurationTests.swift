//
//  FeatureFlagConfigurationTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import Foundation
import Testing
@testable import ARCFirebaseFeatureFlags

@Suite("FeatureFlagConfiguration Tests")
struct FeatureFlagConfigurationTests {
    // MARK: - Default Configuration

    @Test("Default preset has 12-hour fetch interval") func defaultPreset() {
        // Given / When
        let config = FeatureFlagConfiguration.default

        // Then
        #expect(config.minimumFetchInterval == 43200)
    }

    @Test("Development preset has zero fetch interval") func developmentPreset() {
        // Given / When
        let config = FeatureFlagConfiguration.development

        // Then
        #expect(config.minimumFetchInterval == 0)
    }

    @Test("Production preset has 12-hour fetch interval") func productionPreset() {
        // Given / When
        let config = FeatureFlagConfiguration.production

        // Then
        #expect(config.minimumFetchInterval == 43200)
    }

    @Test("Default and production presets have equal intervals") func defaultEqualsProduction() {
        // Given
        let defaultInterval = FeatureFlagConfiguration.default.minimumFetchInterval
        let productionInterval = FeatureFlagConfiguration.production.minimumFetchInterval

        // Then
        #expect(defaultInterval == productionInterval)
    }

    // MARK: - Custom Configuration

    @Test("Custom init stores provided minimumFetchInterval") func customInit() {
        // Given
        let customInterval: TimeInterval = 3600 // 1 hour

        // When
        let config = makeSUT(minimumFetchInterval: customInterval)

        // Then
        #expect(config.minimumFetchInterval == customInterval)
    }

    @Test("Default parameter in init equals 12 hours") func defaultInitParameter() {
        // Given / When
        let config = makeSUT()

        // Then
        #expect(config.minimumFetchInterval == 43200)
    }

    // MARK: - Helpers

    private func makeSUT(minimumFetchInterval: TimeInterval = 43200) -> FeatureFlagConfiguration {
        FeatureFlagConfiguration(minimumFetchInterval: minimumFetchInterval)
    }
}
