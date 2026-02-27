//
//  AIProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import SwiftUI

/// Placeholder provider that crashes with helpful message when accessed.
/// This avoids crashes at module load time while ensuring proper configuration.
private struct PlaceholderAIProvider: AIProviding, @unchecked Sendable {
    func generateContent(prompt _: String,
                         configuration _: AIConfiguration?) async throws -> AIResponse
    {
        placeholderCrash()
    }

    func generateContent(prompt _: String,
                         systemInstruction _: String,
                         configuration _: AIConfiguration?) async throws -> AIResponse
    {
        placeholderCrash()
    }

    func generateStructuredContent(prompt _: String,
                                   responseSchema _: AISchema,
                                   systemInstruction _: String?,
                                   configuration _: AIConfiguration?) async throws -> AIResponse
    {
        placeholderCrash()
    }

    func streamContent(prompt _: String,
                       configuration _: AIConfiguration?) -> AsyncThrowingStream<String, Error>
    {
        placeholderCrash()
    }

    func sendMessage(_: String,
                     history _: [AIMessage],
                     systemInstruction _: String?,
                     configuration _: AIConfiguration?) async throws -> AIResponse
    {
        placeholderCrash()
    }

    func isAvailable() async -> Bool {
        false
    }

    private func placeholderCrash() -> Never {
        fatalError("""
        AIProvider not configured.
        You must set the AI provider in your app's environment:

            .environment(\\.aiProvider, aiProvider)

        Or use a mock provider for previews/testing:

            .environment(\\.aiProvider, MockAIProvider())
        """)
    }
}

extension EnvironmentValues {
    /// The AI provider in the environment.
    @Entry public var aiProvider: any AIProviding = PlaceholderAIProvider()
}
