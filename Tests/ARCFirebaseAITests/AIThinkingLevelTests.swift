//
//  AIThinkingLevelTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-09.
//

import FirebaseAILogic
import Foundation
import Testing
@testable import ARCFirebaseAI

/// Thinking level pass-through (FVRS-335).
///
/// The oracle is the Gemini REST wire format — `generationConfig.thinkingConfig.thinkingLevel`
/// carrying `MINIMAL` / `LOW` / `MEDIUM` / `HIGH` — not ARCFirebase's own types: a mapping that
/// compiles but sends the wrong level would silently change the bill.
struct AIThinkingLevelTests {
    // MARK: - AIConfiguration

    @Test("thinkingLevel defaults to nil so the model keeps its own default") func thinkingLevel_defaultsToNil() {
        // When
        let sut = AIConfiguration()

        // Then
        #expect(sut.thinkingLevel == nil)
    }

    @Test("configurations differing only in thinking level are not equal") func equality_distinguishesThinkingLevel() {
        // Given
        let low = AIConfiguration(thinkingLevel: .low)
        let high = AIConfiguration(thinkingLevel: .high)

        // Then
        #expect(low != high)
        #expect(low == AIConfiguration(thinkingLevel: .low))
    }

    // MARK: - Mapping to the request

    @Test("each level reaches the request as the Gemini wire value",
          arguments: [(AIThinkingLevel.minimal, "MINIMAL"),
                      (.low, "LOW"),
                      (.medium, "MEDIUM"),
                      (.high, "HIGH")])
    func mapping_encodesWireValue(level: AIThinkingLevel, wire: String) throws {
        // Given
        let configuration = AIConfiguration(thinkingLevel: level)

        // When
        let wireConfig = try encodedGenerationConfig(configuration)

        // Then
        let thinking = try #require(wireConfig.thinkingConfig)
        #expect(thinking.thinkingLevel == wire)
        #expect(thinking.thinkingBudget == nil, "level and budget together are rejected by the API")
    }

    @Test("no level sends no thinkingConfig at all") func mapping_omitsThinkingConfigWhenNil() throws {
        // When
        let wireConfig = try encodedGenerationConfig(AIConfiguration(maxOutputTokens: 64))

        // Then
        #expect(wireConfig.thinkingConfig == nil)
        #expect(wireConfig.maxOutputTokens == 64)
    }

    // MARK: - Helpers

    private func encodedGenerationConfig(_ configuration: AIConfiguration) throws -> WireGenerationConfig {
        let config = FirebaseAIProvider.makeGenerationConfig(configuration: configuration)
        let data = try JSONEncoder().encode(config)
        return try JSONDecoder().decode(WireGenerationConfig.self, from: data)
    }
}

// MARK: - Wire Mirror

/// The slice of the Gemini `generationConfig` wire object these tests read.
private struct WireGenerationConfig: Decodable {
    let maxOutputTokens: Int?
    let thinkingConfig: WireThinkingConfig?
}

/// Gemini's `generationConfig.thinkingConfig` wire object.
private struct WireThinkingConfig: Decodable {
    let thinkingLevel: String?
    let thinkingBudget: Int?
}
