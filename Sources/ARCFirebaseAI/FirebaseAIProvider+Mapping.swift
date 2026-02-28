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
                   systemInstruction: String? = nil) -> GenerativeModel
    {
        let genConfig = configuration.map { makeGenerationConfig(configuration: $0) }
        return makeModel(generationConfig: genConfig, systemInstruction: systemInstruction)
    }

    func makeModel(generationConfig: GenerationConfig? = nil,
                   systemInstruction: String? = nil) -> GenerativeModel
    {
        if let instruction = systemInstruction {
            backend.generativeModel(modelName: modelName,
                                    generationConfig: generationConfig,
                                    systemInstruction: ModelContent(role: "system",
                                                                    parts: instruction))
        } else {
            backend.generativeModel(modelName: modelName,
                                    generationConfig: generationConfig)
        }
    }

    func makeGenerationConfig(configuration: AIConfiguration?,
                              responseMIMEType: String? = nil,
                              responseSchema: AISchema? = nil) -> GenerationConfig
    {
        GenerationConfig(temperature: configuration?.temperature,
                         topP: configuration?.topP,
                         topK: configuration?.topK,
                         maxOutputTokens: configuration?.maxOutputTokens,
                         stopSequences: configuration?.stopSequences,
                         responseMIMEType: responseMIMEType,
                         responseSchema: responseSchema)
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
