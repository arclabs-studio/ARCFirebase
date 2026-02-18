//
//  AIProviding.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Foundation

/// Protocol defining AI content generation capabilities.
///
/// Use this protocol for dependency injection to make your code testable
/// and decoupled from Firebase AI.
///
/// ## Usage in Production
///
/// ```swift
/// @Observable
/// final class ChatViewModel {
///     private let ai: any AIProviding
///
///     var response: String = ""
///
///     init(ai: any AIProviding) {
///         self.ai = ai
///     }
///
///     func generate(prompt: String) async throws {
///         let result = try await ai.generateContent(prompt: prompt)
///         response = result.content
///     }
/// }
/// ```
///
/// ## Usage in Tests
///
/// ```swift
/// final class MockAIProvider: AIProviding, @unchecked Sendable {
///     var mockResponse = AIResponse(content: "Mock response")
///
///     func generateContent(
///         prompt: String,
///         configuration: AIConfiguration?
///     ) async throws -> AIResponse {
///         return mockResponse
///     }
///     // ... other methods
/// }
/// ```
///
/// ## Topics
///
/// ### Content Generation
/// - ``generateContent(prompt:configuration:)``
/// - ``generateContent(prompt:systemInstruction:configuration:)``
/// - ``generateStructuredContent(prompt:responseSchema:systemInstruction:configuration:)``
///
/// ### Streaming
/// - ``streamContent(prompt:configuration:)``
///
/// ### Multi-Turn Chat
/// - ``sendMessage(_:history:systemInstruction:configuration:)``
///
/// ### Availability
/// - ``isAvailable()``
///
/// ### Implementations
/// - ``FirebaseAIProvider``
public protocol AIProviding: Sendable {
    /// Generates content from a text prompt.
    ///
    /// - Parameters:
    ///   - prompt: The text prompt to send to the model.
    ///   - configuration: Optional generation configuration. Uses model defaults if nil.
    /// - Returns: The generated response.
    /// - Throws: Generation errors or ``FirebaseError/aiNotAvailable``.
    func generateContent(
        prompt: String,
        configuration: AIConfiguration?
    ) async throws -> AIResponse

    /// Generates content with a system instruction.
    ///
    /// The system instruction guides the model's behavior for the entire interaction.
    ///
    /// - Parameters:
    ///   - prompt: The text prompt to send to the model.
    ///   - systemInstruction: A system-level instruction to guide model behavior.
    ///   - configuration: Optional generation configuration. Uses model defaults if nil.
    /// - Returns: The generated response.
    /// - Throws: Generation errors or ``FirebaseError/aiNotAvailable``.
    func generateContent(
        prompt: String,
        systemInstruction: String,
        configuration: AIConfiguration?
    ) async throws -> AIResponse

    /// Generates structured content using a response schema.
    ///
    /// The model will produce output conforming to the provided schema,
    /// useful for extracting structured data from unstructured text.
    ///
    /// - Parameters:
    ///   - prompt: The text prompt to send to the model.
    ///   - responseSchema: An ``AISchema`` defining the expected response structure.
    ///   - systemInstruction: Optional system-level instruction.
    ///   - configuration: Optional generation configuration. Uses model defaults if nil.
    /// - Returns: The generated response with structured content.
    /// - Throws: Generation errors or ``FirebaseError/aiNotAvailable``.
    func generateStructuredContent(
        prompt: String,
        responseSchema: AISchema,
        systemInstruction: String?,
        configuration: AIConfiguration?
    ) async throws -> AIResponse

    /// Streams content generation as an `AsyncThrowingStream`.
    ///
    /// Use this for real-time display of generated content as it's produced.
    ///
    /// ```swift
    /// for try await chunk in ai.streamContent(prompt: "Tell me a story") {
    ///     text += chunk
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - prompt: The text prompt to send to the model.
    ///   - configuration: Optional generation configuration. Uses model defaults if nil.
    /// - Returns: A stream of text chunks as they are generated.
    func streamContent(
        prompt: String,
        configuration: AIConfiguration?
    ) -> AsyncThrowingStream<String, Error>

    /// Sends a message in a multi-turn conversation.
    ///
    /// Provide conversation history to maintain context across multiple exchanges.
    ///
    /// - Parameters:
    ///   - message: The new message to send.
    ///   - history: Previous messages in the conversation.
    ///   - systemInstruction: Optional system-level instruction.
    ///   - configuration: Optional generation configuration. Uses model defaults if nil.
    /// - Returns: The model's response.
    /// - Throws: Generation errors or ``FirebaseError/aiNotAvailable``.
    func sendMessage(
        _ message: String,
        history: [AIMessage],
        systemInstruction: String?,
        configuration: AIConfiguration?
    ) async throws -> AIResponse

    /// Checks whether the AI service is available.
    ///
    /// Returns `false` if Firebase is not configured or the AI service cannot be reached.
    ///
    /// - Returns: `true` if the service is available.
    func isAvailable() async -> Bool
}

// MARK: - Convenience Methods

extension AIProviding {
    /// Generates content with default configuration.
    public func generateContent(prompt: String) async throws -> AIResponse {
        try await generateContent(prompt: prompt, configuration: nil)
    }

    /// Streams content with default configuration.
    public func streamContent(prompt: String) -> AsyncThrowingStream<String, Error> {
        streamContent(prompt: prompt, configuration: nil)
    }

    /// Sends a message with default parameters.
    public func sendMessage(_ message: String) async throws -> AIResponse {
        try await sendMessage(message, history: [], systemInstruction: nil, configuration: nil)
    }

    /// Sends a message with history.
    public func sendMessage(
        _ message: String,
        history: [AIMessage]
    ) async throws -> AIResponse {
        try await sendMessage(message, history: history, systemInstruction: nil, configuration: nil)
    }
}
