//
//  FirebaseAIProvider+Mapping.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import FirebaseAI
import Foundation

// MARK: - Internal Model Builders

extension FirebaseAIProvider {
    func makeModel(configuration: AIConfiguration? = nil,
                   systemInstruction: String? = nil) -> GenerativeModel {
        let genConfig = configuration.map { makeGenerationConfig(configuration: $0) }
        return makeModel(generationConfig: genConfig,
                         safetySettings: configuration?.safetySettings,
                         systemInstruction: systemInstruction)
    }

    func makeModel(generationConfig: GenerationConfig? = nil,
                   safetySettings: [AISafetySetting]? = nil,
                   systemInstruction: String? = nil) -> GenerativeModel {
        let firebaseSafetySettings = safetySettings.map { $0.map(\.firebaseSetting) }
        return if let instruction = systemInstruction {
            backend.generativeModel(modelName: model.rawValue,
                                    generationConfig: generationConfig,
                                    safetySettings: firebaseSafetySettings,
                                    systemInstruction: ModelContent(role: "system",
                                                                    parts: instruction))
        } else {
            backend.generativeModel(modelName: model.rawValue,
                                    generationConfig: generationConfig,
                                    safetySettings: firebaseSafetySettings)
        }
    }

    func makeGenerationConfig(configuration: AIConfiguration?,
                              responseMIMEType: String? = nil,
                              responseSchema: AISchema? = nil) -> GenerationConfig {
        // Prefer explicit overrides; fall back to values from AIConfiguration
        let mimeType = responseMIMEType ?? configuration?.responseMIMEType
        let schema = responseSchema ?? configuration?.responseSchema
        return GenerationConfig(temperature: configuration?.temperature,
                                topP: configuration?.topP,
                                topK: configuration?.topK,
                                maxOutputTokens: configuration?.maxOutputTokens,
                                stopSequences: configuration?.stopSequences,
                                responseMIMEType: mimeType,
                                responseSchema: schema)
    }
}

// MARK: - Safety Settings Mapping

extension AISafetySetting {
    /// The equivalent `FirebaseAI.SafetySetting`.
    var firebaseSetting: SafetySetting {
        SafetySetting(harmCategory: category.firebaseCategory,
                      threshold: threshold.firebaseThreshold)
    }
}

extension AISafetySetting.Category {
    var firebaseCategory: HarmCategory {
        switch self {
        case .harassment: .harassment
        case .hateSpeech: .hateSpeech
        case .sexuallyExplicit: .sexuallyExplicit
        case .dangerousContent: .dangerousContent
        }
    }
}

extension AISafetySetting.Threshold {
    var firebaseThreshold: SafetySetting.HarmBlockThreshold {
        switch self {
        case .blockLowAndAbove: .blockLowAndAbove
        case .blockMediumAndAbove: .blockMediumAndAbove
        case .blockOnlyHigh: .blockOnlyHigh
        case .blockNone: .blockNone
        case .off: .off
        }
    }
}

// MARK: - Response Mapping

extension FirebaseAIProvider {
    func mapResponse(_ response: GenerateContentResponse) -> AIResponse {
        let text = response.text ?? ""

        let finishReason: AIResponse.FinishReason = response.candidates.first
            .flatMap(\.finishReason)
            .map(mapFinishReason) ?? .unknown

        return AIResponse(content: text,
                          finishReason: finishReason,
                          promptTokenCount: response.usageMetadata?.promptTokenCount,
                          candidatesTokenCount: response.usageMetadata?.candidatesTokenCount,
                          totalTokenCount: response.usageMetadata?.totalTokenCount)
    }

    func mapFinishReason(_ reason: FinishReason) -> AIResponse.FinishReason {
        switch reason {
        case .stop:
            .stop
        case .maxTokens:
            .maxTokens
        case .safety:
            .safety
        case .recitation:
            .recitation
        case .other:
            .other
        default:
            .unknown
        }
    }
}
