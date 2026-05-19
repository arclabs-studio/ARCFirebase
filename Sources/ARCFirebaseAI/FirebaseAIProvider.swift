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
/// let ai = try FirebaseAIProvider(model: "gemini-2.5-flash")
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

    /// Default Gemini model used when no model is specified.
    public static let defaultModel: GeminiModel = .flash25

    // Declared internal (not private) so FirebaseAIProvider+Mapping.swift can access them.
    let model: GeminiModel
    let backend: FirebaseAI
    private let logger = ARCLogger(subsystem: ARCFirebaseLogSubsystem.current, category: "FirebaseAI")

    // MARK: - Initialization

    /// Creates a Firebase AI provider.
    ///
    /// - Parameter model: The Gemini model to use. Default: ``GeminiModel/flash25``.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public init(model: GeminiModel = FirebaseAIProvider.defaultModel) throws {
        try FirebaseManager.ensureConfigured()
        self.model = model
        backend = FirebaseAI.firebaseAI(backend: .googleAI())
        logger.info("FirebaseAIProvider initialized with model: \(model.rawValue)")
    }

    // MARK: - AIProviding Implementation

    public func generateContent(prompt: String,
                                configuration: AIConfiguration?) async throws -> AIResponse {
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

    public func generateContent(prompt: String,
                                systemInstruction: String,
                                configuration: AIConfiguration?) async throws -> AIResponse {
        logger.info("Generating content with system instruction")

        let model = makeModel(configuration: configuration,
                              systemInstruction: systemInstruction)

        do {
            let response = try await model.generateContent(prompt)
            logger.info("Content generated successfully")
            return mapResponse(response)
        } catch {
            logger.error("Content generation failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func generateStructuredContent(prompt: String,
                                          responseSchema: AISchema,
                                          systemInstruction: String?,
                                          configuration: AIConfiguration?) async throws -> AIResponse {
        logger.info("Generating structured content")

        let genConfig = makeGenerationConfig(configuration: configuration,
                                             responseMIMEType: "application/json",
                                             responseSchema: responseSchema)

        let model = makeModel(generationConfig: genConfig,
                              systemInstruction: systemInstruction)

        do {
            let response = try await model.generateContent(prompt)
            logger.info("Structured content generated successfully")
            return mapResponse(response)
        } catch {
            logger.error("Structured content generation failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func streamContent(prompt: String,
                              configuration: AIConfiguration?) -> AsyncThrowingStream<String, Error> {
        logger.info("Streaming content for prompt (\(prompt.prefix(50))...)")

        let model = makeModel(configuration: configuration)

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let stream = try model.generateContentStream(prompt)
                    for try await chunk in stream {
                        if let text = chunk.text {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                    logger.info("Stream completed successfully")
                } catch {
                    logger.error("Stream failed: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    public func sendMessage(_ message: String,
                            history: [AIMessage],
                            systemInstruction: String?,
                            configuration: AIConfiguration?) async throws -> AIResponse {
        logger.info("Sending message with \(history.count) history items")

        let model = makeModel(configuration: configuration,
                              systemInstruction: systemInstruction)

        let modelHistory = history.map { msg in
            ModelContent(role: msg.role.rawValue,
                         parts: msg.content)
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
        // Firebase was validated at init time; a live instance is always configured.
        true
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
    /// - Parameter model: The Gemini model to use. Default: ``GeminiModel/flash25``.
    /// - Returns: A configured ``FirebaseAIProvider`` instance.
    /// - Throws: ``FirebaseError/notConfigured`` if Firebase hasn't been initialized.
    public static func create(model: GeminiModel = FirebaseAIProvider.defaultModel) throws -> FirebaseAIProvider {
        try FirebaseAIProvider(model: model)
    }

    /// Default live instance for production use (Gemini 2.5 Flash).
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
            fatalError("""
            FirebaseAIProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(error.localizedDescription)
            """)
        }
    }
}
