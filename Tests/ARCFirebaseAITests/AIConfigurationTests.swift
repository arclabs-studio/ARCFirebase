//
//  AIConfigurationTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Testing
@testable import ARCFirebaseAI

@Suite("AIConfiguration Tests") struct AIConfigurationTests {
    // MARK: - Default Preset

    @Test("Default preset has expected values") func defaultPreset() {
        // Given/When
        let sut = AIConfiguration.default

        // Then
        #expect(sut.temperature == 1.0)
        #expect(sut.maxOutputTokens == 8192)
        #expect(sut.topP == 0.95)
        #expect(sut.topK == 40)
        #expect(sut.stopSequences == nil)
    }

    // MARK: - Creative Preset

    @Test("Creative preset has higher temperature") func creativePreset() {
        // Given/When
        let sut = AIConfiguration.creative

        // Then
        #expect(sut.temperature == 1.5)
        #expect(sut.maxOutputTokens == 8192)
        #expect(sut.topP == 0.98)
        #expect(sut.topK == 64)
    }

    // MARK: - Factual Preset

    @Test("Factual preset has lower temperature") func factualPreset() {
        // Given/When
        let sut = AIConfiguration.factual

        // Then
        #expect(sut.temperature == 0.3)
        #expect(sut.maxOutputTokens == 4096)
        #expect(sut.topP == 0.8)
        #expect(sut.topK == 20)
    }

    // MARK: - Structured Preset

    @Test("Structured preset has very low temperature") func structuredPreset() {
        // Given/When
        let sut = AIConfiguration.structured

        // Then
        #expect(sut.temperature == 0.1)
        #expect(sut.maxOutputTokens == 4096)
        #expect(sut.topP == 0.7)
        #expect(sut.topK == 10)
    }

    // MARK: - Custom Initialization

    @Test("Custom configuration accepts all parameters") func customInit() {
        // Given/When
        let sut = AIConfiguration(temperature: 0.7,
                                  maxOutputTokens: 2048,
                                  topP: 0.9,
                                  topK: 30,
                                  stopSequences: ["END", "STOP"])

        // Then
        #expect(sut.temperature == 0.7)
        #expect(sut.maxOutputTokens == 2048)
        #expect(sut.topP == 0.9)
        #expect(sut.topK == 30)
        #expect(sut.stopSequences == ["END", "STOP"])
    }

    @Test("Default init has nil values") func defaultInit() {
        // Given/When
        let sut = AIConfiguration()

        // Then
        #expect(sut.temperature == nil)
        #expect(sut.maxOutputTokens == nil)
        #expect(sut.topP == nil)
        #expect(sut.topK == nil)
        #expect(sut.stopSequences == nil)
    }

    // MARK: - Equatable

    @Test("Configurations with same values are equal") func equality() {
        // Given
        let config1 = AIConfiguration(temperature: 0.5, maxOutputTokens: 1024)
        let config2 = AIConfiguration(temperature: 0.5, maxOutputTokens: 1024)

        // Then
        #expect(config1 == config2)
    }

    @Test("Configurations with different values are not equal") func inequality() {
        // Given
        let config1 = AIConfiguration(temperature: 0.5)
        let config2 = AIConfiguration(temperature: 0.8)

        // Then
        #expect(config1 != config2)
    }

    @Test("Presets are not equal to each other") func presetInequality() {
        #expect(AIConfiguration.default != AIConfiguration.creative)
        #expect(AIConfiguration.factual != AIConfiguration.structured)
        #expect(AIConfiguration.creative != AIConfiguration.factual)
    }
}
