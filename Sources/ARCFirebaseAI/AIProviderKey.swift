//
//  AIProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import SwiftUI

/// SwiftUI Environment key for AI provider.
///
/// This allows passing the AI provider through the SwiftUI environment:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let ai: any AIProviding
///
///     init() {
///         do {
///             ai = try FirebaseAIProvider.create()
///         } catch {
///             fatalError("Firebase not configured: \(error)")
///         }
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.aiProvider, ai)
///         }
///     }
/// }
///
/// struct ChatView: View {
///     @Environment(\.aiProvider) var ai
///
///     var body: some View {
///         Button("Generate") {
///             Task {
///                 let response = try await ai.generateContent(prompt: "Hello")
///                 print(response.content)
///             }
///         }
///     }
/// }
/// ```
///
/// - Important: You must explicitly set `.environment(\.aiProvider, provider)` in your app.
///   The default value will crash if accessed without setting a provider first.
public struct AIProviderKey: EnvironmentKey {
    public static let defaultValue: any AIProviding = PlaceholderAIProvider()
}

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderAIProvider: AIProviding, @unchecked Sendable {
    func generateContent(
        prompt _: String,
        configuration _: AIConfiguration?
    ) async throws -> AIResponse {
        placeholderCrash()
    }

    func generateContent(
        prompt _: String,
        systemInstruction _: String,
        configuration _: AIConfiguration?
    ) async throws -> AIResponse {
        placeholderCrash()
    }

    func generateStructuredContent(
        prompt _: String,
        responseSchema _: AISchema,
        systemInstruction _: String?,
        configuration _: AIConfiguration?
    ) async throws -> AIResponse {
        placeholderCrash()
    }

    func streamContent(
        prompt _: String,
        configuration _: AIConfiguration?
    ) -> AsyncThrowingStream<String, Error> {
        placeholderCrash()
    }

    func sendMessage(
        _: String,
        history _: [AIMessage],
        systemInstruction _: String?,
        configuration _: AIConfiguration?
    ) async throws -> AIResponse {
        placeholderCrash()
    }

    func isAvailable() async -> Bool {
        false
    }

    private func placeholderCrash() -> Never {
        fatalError(
            """
            AIProvider not configured.
            You must set the AI provider in your app's environment:

                .environment(\\.aiProvider, aiProvider)

            Or use a mock provider for previews/testing:

                .environment(\\.aiProvider, MockAIProvider())
            """
        )
    }
}

extension EnvironmentValues {
    /// The AI provider in the environment.
    public var aiProvider: any AIProviding {
        get { self[AIProviderKey.self] }
        set { self[AIProviderKey.self] = newValue }
    }
}
