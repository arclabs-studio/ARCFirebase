//
//  FirebaseAIProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import ARCFirebaseCore
import ARCLogger
import FirebaseAI
import Foundation

/// Firebase implementation of ``AIProviding``.
///
/// This is the production AI provider that uses Firebase AI (Gemini) for content generation.
///
/// ## Initialization
///
/// ```swift
/// // Create an instance with the default model
/// let ai = try FirebaseAIProvider()
///
/// // Or specify a model
/// let ai = try FirebaseAIProvider(model: "gemini-2.0-flash")
///
/// // Or use the convenience default
/// let ai = FirebaseAIProvider.live
/// ```
///
/// ## SwiftUI Integration
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let ai = FirebaseAIProvider.live
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.aiProvider, ai)
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initialization
/// - ``init(model:)``
/// - ``create(model:)``
/// - ``live``
///
/// ### AIProviding Implementation
/// - ``generateContent(prompt:configuration:)``
/// - ``generateContent(prompt:systemInstruction:configuration:)``
/// - ``generateStructuredContent(prompt:responseSchema:systemInstruction:configuration:)``
/// - ``streamContent(prompt:configuration:)``
/// - ``sendMessage(_:history:systemInstruction:configuration:)``
/// - ``isAvailable()``
public final class FirebaseAIProvider: AIProviding, @unchecked Sendable {
    // MARK: - Properties

    private let modelName: String
    private let logger = ARCLogger(category: "FirebaseAI", subsystem: "com.arclabs-studio.arcfirebase")

    // MARK: - Initialization

    /// Creates a Firebase AI provider.
    ///
    /// - Parameter model: The Gemini model name. Default: `"gemini-2.0-flash"`.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init(model: String = "gemini-2.0-flash") throws {
        try FirebaseManager.ensureConfigured()
        self.modelName = model
        logger.info("FirebaseAIProvider initialized with model: \(model)")
    }

    // MARK: - AIProviding Implementation

    public func generateContent(
        prompt: String,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        logger.info("Generating content for prompt (\(prompt.prefix(50))...)")

        let model = makeModel(configuration: configuration)

        do {
            let response = try await model.generateContent(prompt)
            logger.info("Content generated successfully")
            return mapResponse(response)
        } catch {
            logger.error("Content generation failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func generateContent(
        prompt: String,
        systemInstruction: String,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        logger.info("Generating content with system instruction")

        let model = makeModel(
            configuration: configuration,
            systemInstruction: systemInstruction
        )

        do {
            let response = try await model.generateContent(prompt)
            logger.info("Content generated successfully")
            return mapResponse(response)
        } catch {
            logger.error("Content generation failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func generateStructuredContent(
        prompt: String,
        responseSchema: Schema,
        systemInstruction: String?,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        logger.info("Generating structured content")

        let genConfig = makeGenerationConfig(
            configuration: configuration,
            responseMIMEType: "application/json",
            responseSchema: responseSchema
        )

        let model = makeModel(
            generationConfig: genConfig,
            systemInstruction: systemInstruction
        )

        do {
            let response = try await model.generateContent(prompt)
            logger.info("Structured content generated successfully")
            return mapResponse(response)
        } catch {
            logger.error("Structured content generation failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func streamContent(
        prompt: String,
        configuration: AIConfiguration?
    ) -> AsyncThrowingStream<String, Error> {
        logger.info("Streaming content for prompt (\(prompt.prefix(50))...)")

        let model = makeModel(configuration: configuration)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let stream = try model.generateContentStream(prompt)
                    for try await chunk in stream {
                        if let text = chunk.text {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                    self.logger.info("Stream completed successfully")
                } catch {
                    self.logger.error("Stream failed: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func sendMessage(
        _ message: String,
        history: [AIMessage],
        systemInstruction: String?,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        logger.info("Sending message with \(history.count) history items")

        let model = makeModel(
            configuration: configuration,
            systemInstruction: systemInstruction
        )

        let modelHistory = history.map { msg in
            ModelContent(
                role: msg.role.rawValue,
                parts: msg.content
            )
        }

        let chat = model.startChat(history: modelHistory)

        do {
            let response = try await chat.sendMessage(message)
            logger.info("Message sent successfully")
            return mapResponse(response)
        } catch {
            logger.error("Send message failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func isAvailable() async -> Bool {
        do {
            try FirebaseManager.ensureConfigured()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Private Helpers

    private func makeModel(
        configuration: AIConfiguration? = nil,
        systemInstruction: String? = nil
    ) -> GenerativeModel {
        let genConfig = configuration.map { makeGenerationConfig(configuration: $0) }
        return makeModel(generationConfig: genConfig, systemInstruction: systemInstruction)
    }

    private func makeModel(
        generationConfig: GenerationConfig? = nil,
        systemInstruction: String? = nil
    ) -> GenerativeModel {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())

        if let instruction = systemInstruction {
            return ai.generativeModel(
                modelName: modelName,
                generationConfig: generationConfig,
                systemInstruction: ModelContent(
                    role: "system",
                    parts: instruction
                )
            )
        } else {
            return ai.generativeModel(
                modelName: modelName,
                generationConfig: generationConfig
            )
        }
    }

    private func makeGenerationConfig(
        configuration: AIConfiguration?,
        responseMIMEType: String? = nil,
        responseSchema: Schema? = nil
    ) -> GenerationConfig {
        GenerationConfig(
            temperature: configuration?.temperature,
            topP: configuration?.topP,
            topK: configuration?.topK,
            maxOutputTokens: configuration?.maxOutputTokens,
            stopSequences: configuration?.stopSequences,
            responseMIMEType: responseMIMEType,
            responseSchema: responseSchema
        )
    }

    private func mapResponse(_ response: GenerateContentResponse) -> AIResponse {
        let text = response.text ?? ""

        let finishReason: AIResponse.FinishReason
        if let candidate = response.candidates.first,
           let reason = candidate.finishReason {
            finishReason = mapFinishReason(reason)
        } else {
            finishReason = .unknown
        }

        return AIResponse(
            content: text,
            finishReason: finishReason,
            promptTokenCount: response.usageMetadata?.promptTokenCount,
            candidatesTokenCount: response.usageMetadata?.candidatesTokenCount,
            totalTokenCount: response.usageMetadata?.totalTokenCount
        )
    }

    private func mapFinishReason(_ reason: FinishReason) -> AIResponse.FinishReason {
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

// MARK: - Factory Methods

extension FirebaseAIProvider {
    /// Creates a new instance with explicit error handling.
    ///
    /// ```swift
    /// do {
    ///     let ai = try FirebaseAIProvider.create()
    /// } catch {
    ///     // Handle configuration error
    /// }
    /// ```
    ///
    /// - Parameter model: The Gemini model name. Default: `"gemini-2.0-flash"`.
    /// - Returns: A configured ``FirebaseAIProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create(model: String = "gemini-2.0-flash") throws -> FirebaseAIProvider {
        try FirebaseAIProvider(model: model)
    }

    /// Default live instance for production use.
    ///
    /// ```swift
    /// let ai = FirebaseAIProvider.live
    /// ```
    ///
    /// - Important: This will crash if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first.
    public static var live: FirebaseAIProvider {
        do {
            return try create()
        } catch {
            fatalError(
                """
                FirebaseAIProvider initialization failed.
                Ensure FirebaseManager.shared.configure() is called before accessing .live.
                Error: \(error.localizedDescription)
                """
            )
        }
    }
}
