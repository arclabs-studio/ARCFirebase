//
//  AISafetySettingTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-09-01.
//

import FirebaseAI
import Foundation
import Testing
@testable import ARCFirebaseAI

struct AISafetySettingTests {
    // MARK: - Firebase Mapping

    @Test("Categories map to the matching FirebaseAI harm categories") func categoriesMapToFirebase() {
        // Given/When/Then
        #expect(AISafetySetting.Category.harassment.firebaseCategory == .harassment)
        #expect(AISafetySetting.Category.hateSpeech.firebaseCategory == .hateSpeech)
        #expect(AISafetySetting.Category.sexuallyExplicit.firebaseCategory == .sexuallyExplicit)
        #expect(AISafetySetting.Category.dangerousContent.firebaseCategory == .dangerousContent)
    }

    @Test("Thresholds map to the matching FirebaseAI proto values",
          arguments: [(AISafetySetting.Threshold.blockLowAndAbove, "BLOCK_LOW_AND_ABOVE"),
                      (.blockMediumAndAbove, "BLOCK_MEDIUM_AND_ABOVE"),
                      (.blockOnlyHigh, "BLOCK_ONLY_HIGH"),
                      (.blockNone, "BLOCK_NONE"),
                      (.off, "OFF")])
    func thresholdsMapToFirebase(_ threshold: AISafetySetting.Threshold, _ proto: String) throws {
        // Given
        let setting = AISafetySetting(category: .harassment, threshold: threshold)

        // When — SafetySetting is Encodable; the proto string is the wire truth
        let data = try JSONEncoder().encode(setting.firebaseSetting)
        let json = try #require(String(data: data, encoding: .utf8))

        // Then
        #expect(json.contains("\"threshold\":\"\(proto)\""))
    }

    @Test("Mapped setting carries the category on the wire") func mappedSettingCarriesCategory() throws {
        // Given
        let setting = AISafetySetting(category: .dangerousContent, threshold: .blockMediumAndAbove)

        // When
        let data = try JSONEncoder().encode(setting.firebaseSetting)
        let json = try #require(String(data: data, encoding: .utf8))

        // Then
        #expect(json.contains("\"category\":\"HARM_CATEGORY_DANGEROUS_CONTENT\""))
    }

    // MARK: - Standard Moderation

    @Test("standardModeration covers all four categories at blockMediumAndAbove")
    func standardModerationCoversAllCategories() {
        // Given/When
        let settings = AISafetySetting.standardModeration

        // Then
        #expect(settings.count == AISafetySetting.Category.allCases.count)
        #expect(Set(settings.map(\.category)) == Set(AISafetySetting.Category.allCases))
        #expect(settings.allSatisfy { $0.threshold == .blockMediumAndAbove })
    }

    // MARK: - AIConfiguration Integration

    @Test("AIConfiguration defaults to nil safetySettings (non-breaking)")
    func configurationDefaultsToNilSafetySettings() {
        // Given/When
        let sut = AIConfiguration(temperature: 0.4)

        // Then
        #expect(sut.safetySettings == nil)
    }

    @Test("AIConfiguration stores explicit safetySettings and factors them into equality")
    func configurationStoresSafetySettings() {
        // Given
        let moderated = AIConfiguration(temperature: 0.4,
                                        safetySettings: AISafetySetting.standardModeration)
        let unmoderated = AIConfiguration(temperature: 0.4)

        // Then
        #expect(moderated.safetySettings == AISafetySetting.standardModeration)
        #expect(moderated != unmoderated)
        #expect(moderated == AIConfiguration(temperature: 0.4,
                                             safetySettings: AISafetySetting.standardModeration))
    }
}
