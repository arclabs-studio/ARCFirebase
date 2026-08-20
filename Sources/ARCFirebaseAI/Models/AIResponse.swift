//
//  AIResponse.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Foundation

/// Response from an AI content generation request.
///
/// Contains the generated content, finish reason, and optional token usage metadata.
///
/// ## Usage
///
/// ```swift
/// let response = try await ai.generateContent(prompt: "Hello")
/// print(response.content)
///
/// if let usage = response.promptTokenCount {
///     print("Prompt tokens: \(usage)")
/// }
/// ```
///
/// ## Topics
///
/// ### Properties
/// - ``content``
/// - ``finishReason``
/// - ``promptTokenCount``
/// - ``candidatesTokenCount``
/// - ``totalTokenCount``
public struct AIResponse: Sendable, Equatable {
    /// The generated text content.
    public let content: String

    /// The reason generation stopped.
    public let finishReason: FinishReason

    /// Number of tokens in the prompt.
    public let promptTokenCount: Int?

    /// Number of tokens in the generated response.
    public let candidatesTokenCount: Int?

    /// Total tokens used (prompt + response).
    public let totalTokenCount: Int?

    /// Grounding metadata from the provider's search grounding, if enabled.
    ///
    /// `nil` when grounding was not requested (`AIConfiguration.groundingEnabled == false`)
    /// or when the provider/model does not support grounding.
    public let groundingMetadata: AIGroundingMetadata?

    /// Creates an AI response.
    ///
    /// - Parameters:
    ///   - content: The generated text content.
    ///   - finishReason: The reason generation stopped.
    ///   - promptTokenCount: Number of tokens in the prompt.
    ///   - candidatesTokenCount: Number of tokens in the response.
    ///   - totalTokenCount: Total tokens used.
    ///   - groundingMetadata: Grounding metadata, if grounding was enabled and supported.
    public init(content: String,
                finishReason: FinishReason = .stop,
                promptTokenCount: Int? = nil,
                candidatesTokenCount: Int? = nil,
                totalTokenCount: Int? = nil,
                groundingMetadata: AIGroundingMetadata? = nil) {
        self.content = content
        self.finishReason = finishReason
        self.promptTokenCount = promptTokenCount
        self.candidatesTokenCount = candidatesTokenCount
        self.totalTokenCount = totalTokenCount
        self.groundingMetadata = groundingMetadata
    }

    /// The reason content generation finished.
    public enum FinishReason: String, Sendable, Equatable {
        /// Generation completed naturally.
        case stop = "STOP"

        /// Generation stopped due to reaching the maximum token limit.
        case maxTokens = "MAX_TOKENS"

        /// Generation stopped due to safety filtering.
        case safety = "SAFETY"

        /// Generation stopped due to recitation detection.
        case recitation = "RECITATION"

        /// Generation stopped for another reason.
        case other = "OTHER"

        /// The finish reason is unknown.
        case unknown = "UNKNOWN"
    }
}
