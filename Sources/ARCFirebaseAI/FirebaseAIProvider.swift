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
/// let ai = try FirebaseAIProvider(model: .flash36)
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
/// `@unchecked Sendable` rationale: the Firebase SDK `FirebaseAI` backend type
/// is not statically `Sendable` (Objective-C-bridged), and `GeminiModel` here is
/// `Sendable` but stored alongside it. All stored properties are `let`, set once
/// in `init`, never mutated. `FirebaseAI` is documented as thread-safe — each
/// request returns its own session — so cross-actor reads of `backend` and
/// `model` are safe.
public final class FirebaseAIProvider: AIProviding, @unchecked Sendable {
    // MARK: - Properties

    /// Default Gemini model used when no model is specified.
    public static let defaultModel: GeminiModel = .flash36

    // Declared internal (not private) so FirebaseAIProvider+Mapping.swift can access them.
    let model: GeminiModel
    let backend: FirebaseAI
    private let logger = ARCLogger(subsystem: ARCFirebaseLogSubsystem.current, category: "FirebaseAI")

    // MARK: - Diagnostics

    /// Builds a rich but bounded diagnostic string for logging FirebaseAI errors.
    ///
    /// `GenerateContentError` has no `LocalizedError`/`CustomNSError` conformance, so
    /// `localizedDescription` collapses to a useless `"GenerateContentError 0"`. This
    /// recurses via `String(describing:)` into the underlying `BackendError` to surface
    /// `httpResponseCode` / `message` / `status`. The stopped/blocked cases are bounded so
    /// the full `GenerateContentResponse` (and any model/user-adjacent content) is never
    /// dumped.
    ///
    /// - Parameter error: The error thrown by a FirebaseAI call.
    /// - Returns: A diagnosable, PII-safe description for logging.
    static func diagnosticDescription(for error: Error) -> String {
        guard let genError = error as? GenerateContentError else {
            return String(describing: error)
        }
        switch genError {
        case .internalError, .promptImageContentError:
            // Recurses into the underlying BackendError — surfaces the useful fields.
            return String(describing: error)
        case let .responseStoppedEarly(reason, _):
            // Do NOT dump the response; the reason is the actionable signal.
            return "GenerateContentError.responseStoppedEarly(reason: \(reason))"
        case let .promptBlocked(response):
            let reason = response.promptFeedback?.blockReason.map { String(describing: $0) } ?? "unknown"
            let message = response.promptFeedback?.blockReasonMessage?.prefix(300) ?? ""
            return "GenerateContentError.promptBlocked(blockReason: \(reason), message: \(message))"
        }
    }

    // MARK: - Initialization

    /// Creates a Firebase AI provider.
    ///
    /// - Parameter model: The Gemini model to use. Default: ``GeminiModel/flash36``.
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
            logger.error("Content generation failed: \(Self.diagnosticDescription(for: error))")
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
            logger.error("Content generation failed: \(Self.diagnosticDescription(for: error))")
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
            logger.error("Structured content generation failed: \(Self.diagnosticDescription(for: error))")
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
                    logger.error("Stream failed: \(Self.diagnosticDescription(for: error))")
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
            logger.error("Send message failed: \(Self.diagnosticDescription(for: error))")
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
    /// - Parameter model: The Gemini model to use. Default: ``GeminiModel/flash36``.
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
    /// - Important: Production-only. Calls `fatalError` if Firebase is not configured.
    ///              Call ``FirebaseManager/configure()`` first. Tests should use
    ///              ``create(model:)`` (throws) or a mock conforming to ``AIProviding``
    ///              to avoid the trap.
    public static var live: FirebaseAIProvider {
        do {
            return try create()
        } catch {
            fatalError("""
            FirebaseAIProvider initialization failed.
            Ensure FirebaseManager.shared.configure() is called before accessing .live.
            Error: \(diagnosticDescription(for: error))
            """)
        }
    }
}
