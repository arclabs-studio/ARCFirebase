//
//  AIConfiguration.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import FirebaseAI
import Foundation

/// Configuration for AI content generation.
///
/// Use this struct to customize generation behavior such as temperature,
/// token limits, and sampling parameters.
///
/// ## Usage
///
/// ```swift
/// // Use a preset
/// let response = try await ai.generateContent(
///     prompt: "Describe this restaurant",
///     configuration: .creative
/// )
///
/// // Custom configuration
/// let config = AIConfiguration(
///     temperature: 0.5,
///     maxOutputTokens: 1024
/// )
/// let response = try await ai.generateContent(
///     prompt: "Summarize the menu",
///     configuration: config
/// )
/// ```
///
/// ## Topics
///
/// ### Properties
/// - ``temperature``
/// - ``maxOutputTokens``
/// - ``topP``
/// - ``topK``
/// - ``stopSequences``
///
/// ### Presets
/// - ``default``
/// - ``creative``
/// - ``factual``
/// - ``structured``
/// `@unchecked Sendable` because `AISchema` (= `FirebaseAI.Schema`) may not satisfy
/// the automatic Sendable check. The schema is set once at creation and never mutated.
public struct AIConfiguration: @unchecked Sendable, Equatable {
    /// Controls randomness in generation. Higher values produce more creative output.
    ///
    /// Range: 0.0 to 2.0. Default: 1.0
    public let temperature: Float?

    /// Maximum number of tokens to generate in the response.
    ///
    /// Default: 8192
    public let maxOutputTokens: Int?

    /// Nucleus sampling parameter. Only tokens with cumulative probability up to `topP` are considered.
    ///
    /// Range: 0.0 to 1.0. Default: 0.95
    public let topP: Float?

    /// Only the top `topK` most probable tokens are considered for generation.
    ///
    /// Default: 40
    public let topK: Int?

    /// Sequences that will stop generation when encountered.
    public let stopSequences: [String]?

    /// MIME type for the response (e.g. `"application/json"` for structured output).
    ///
    /// `nil` means the provider uses its default (plain text). Pair with
    /// `responseSchema` to constrain the response shape.
    public let responseMIMEType: String?

    /// JSON Schema for structured output.
    ///
    /// Used together with `responseMIMEType: "application/json"`. When provided,
    /// the model constrains its response to match this schema. `nil` means no
    /// schema constraint.
    public let responseSchema: AISchema?

    /// When `true`, the provider uses search grounding to verify factual claims
    /// (if supported by the provider and model). Providers that do not support
    /// grounding silently ignore this flag.
    public let groundingEnabled: Bool

    /// Creates an AI configuration with custom settings.
    ///
    /// - Parameters:
    ///   - temperature: Controls randomness (0.0-2.0). Default: nil (uses model default).
    ///   - maxOutputTokens: Maximum tokens to generate. Default: nil (uses model default).
    ///   - topP: Nucleus sampling parameter (0.0-1.0). Default: nil (uses model default).
    ///   - topK: Top-K sampling parameter. Default: nil (uses model default).
    ///   - stopSequences: Sequences that stop generation. Default: nil.
    ///   - responseMIMEType: MIME type for the response. Default: nil (plain text).
    ///   - responseSchema: JSON schema for structured output. Default: nil.
    ///   - groundingEnabled: Enable search grounding when supported. Default: false.
    public init(temperature: Float? = nil,
                maxOutputTokens: Int? = nil,
                topP: Float? = nil,
                topK: Int? = nil,
                stopSequences: [String]? = nil,
                responseMIMEType: String? = nil,
                responseSchema: AISchema? = nil,
                groundingEnabled: Bool = false) {
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
        self.topP = topP
        self.topK = topK
        self.stopSequences = stopSequences
        self.responseMIMEType = responseMIMEType
        self.responseSchema = responseSchema
        self.groundingEnabled = groundingEnabled
    }

    // MARK: - Equatable

    /// Schema equality is best-effort: two configurations are considered equal when
    /// all scalar fields match and both `responseSchema` values are either both
    /// `nil` or both non-`nil`, because `AISchema` is not itself `Equatable`.
    public static func == (lhs: AIConfiguration, rhs: AIConfiguration) -> Bool {
        lhs.temperature == rhs.temperature &&
            lhs.maxOutputTokens == rhs.maxOutputTokens &&
            lhs.topP == rhs.topP &&
            lhs.topK == rhs.topK &&
            lhs.stopSequences == rhs.stopSequences &&
            lhs.responseMIMEType == rhs.responseMIMEType &&
            lhs.groundingEnabled == rhs.groundingEnabled &&
            (lhs.responseSchema == nil) == (rhs.responseSchema == nil)
    }

    // MARK: - Presets

    /// Default configuration suitable for most use cases.
    ///
    /// - Temperature: 1.0
    /// - Max output tokens: 8192
    /// - Top P: 0.95
    /// - Top K: 40
    public static let `default` = AIConfiguration(temperature: 1.0,
                                                  maxOutputTokens: 8192,
                                                  topP: 0.95,
                                                  topK: 40)

    /// Creative configuration for imaginative, varied responses.
    ///
    /// Higher temperature and broader sampling produce more diverse output.
    ///
    /// - Temperature: 1.5
    /// - Max output tokens: 8192
    /// - Top P: 0.98
    /// - Top K: 64
    public static let creative = AIConfiguration(temperature: 1.5,
                                                 maxOutputTokens: 8192,
                                                 topP: 0.98,
                                                 topK: 64)

    /// Factual configuration for precise, consistent responses.
    ///
    /// Lower temperature and narrower sampling favor the most likely tokens.
    ///
    /// - Temperature: 0.3
    /// - Max output tokens: 4096
    /// - Top P: 0.8
    /// - Top K: 20
    public static let factual = AIConfiguration(temperature: 0.3,
                                                maxOutputTokens: 4096,
                                                topP: 0.8,
                                                topK: 20)

    /// Structured configuration for JSON and structured output.
    ///
    /// Very low temperature for deterministic, parseable responses.
    ///
    /// - Temperature: 0.1
    /// - Max output tokens: 4096
    /// - Top P: 0.7
    /// - Top K: 10
    public static let structured = AIConfiguration(temperature: 0.1,
                                                   maxOutputTokens: 4096,
                                                   topP: 0.7,
                                                   topK: 10)
}
