//
//  MockAIProvider.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import ARCFirebaseAI
import Foundation
import os

// MARK: - MockAIProvider

/// A mock implementation of `AIProviding` for SwiftUI previews and demo mode.
///
/// This provider simulates AI content generation without connecting to Firebase AI,
/// making it perfect for:
/// - SwiftUI previews
/// - Demo mode (no Firebase configuration)
/// - Unit testing
///
/// ## Example Usage
///
/// ```swift
/// let mockAI = MockAIProvider()
/// let response = try await mockAI.generateContent(prompt: "Hello")
/// print(response.content) // "This is a mock AI response..."
/// ```
final class MockAIProvider: AIProviding {
    private struct State {
        var simulatedDelay: TimeInterval = 0.8
        var customResponse: String?
        var generateCount: Int = 0
        var streamCount: Int = 0
        var chatCount: Int = 0
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: Mock Configuration

    /// Simulated delay in seconds for async operations.
    var simulatedDelay: TimeInterval {
        get { state.withLock { $0.simulatedDelay } }
        set { state.withLock { $0.simulatedDelay = newValue } }
    }

    /// Custom response override. If nil, generates contextual responses.
    var customResponse: String? {
        get { state.withLock { $0.customResponse } }
        set { state.withLock { $0.customResponse = newValue } }
    }

    // MARK: Call Tracking

    /// Number of generate operations performed.
    var generateCount: Int {
        state.withLock { $0.generateCount }
    }

    /// Number of stream operations performed.
    var streamCount: Int {
        state.withLock { $0.streamCount }
    }

    /// Number of chat messages sent.
    var chatCount: Int {
        state.withLock { $0.chatCount }
    }

    // MARK: AIProviding Implementation

    func generateContent(prompt: String,
                         configuration _: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.generateCount += 1 }
        try await Task.sleep(for: .seconds(simulatedDelay))

        let content = customResponse ?? mockResponse(for: prompt)
        return AIResponse(content: content,
                          finishReason: .stop,
                          promptTokenCount: prompt.count / 4,
                          candidatesTokenCount: content.count / 4,
                          totalTokenCount: (prompt.count + content.count) / 4)
    }

    func generateContent(prompt: String,
                         systemInstruction _: String,
                         configuration: AIConfiguration?) async throws -> AIResponse {
        try await generateContent(prompt: prompt, configuration: configuration)
    }

    func generateStructuredContent(prompt: String,
                                   responseSchema _: AISchema,
                                   systemInstruction _: String?,
                                   configuration _: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.generateCount += 1 }
        try await Task.sleep(for: .seconds(simulatedDelay))

        let json = """
        {"name": "Osteria Francescana", "rating": 5, "cuisine": "Italian"}
        """
        return AIResponse(content: json,
                          finishReason: .stop,
                          promptTokenCount: prompt.count / 4,
                          candidatesTokenCount: json.count / 4,
                          totalTokenCount: (prompt.count + json.count) / 4)
    }

    func streamContent(prompt: String,
                       configuration _: AIConfiguration?) -> AsyncThrowingStream<String, Error> {
        state.withLock { $0.streamCount += 1 }
        let response = customResponse ?? mockResponse(for: prompt)
        let delay = simulatedDelay

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    // Simulate word-by-word streaming
                    let words = response.split(separator: " ")
                    for (index, word) in words.enumerated() {
                        try await Task.sleep(for: .seconds(delay / Double(words.count)))
                        let chunk = index == 0 ? String(word) : " " + String(word)
                        continuation.yield(chunk)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func sendMessage(_ message: String,
                     history: [AIMessage],
                     systemInstruction _: String?,
                     configuration _: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.chatCount += 1 }
        try await Task.sleep(for: .seconds(simulatedDelay))

        let content = customResponse ?? mockChatResponse(for: message, history: history)
        return AIResponse(content: content,
                          finishReason: .stop,
                          promptTokenCount: message.count / 4,
                          candidatesTokenCount: content.count / 4,
                          totalTokenCount: (message.count + content.count) / 4)
    }

    func isAvailable() async -> Bool {
        true
    }

    // MARK: Private Helpers

    private func mockResponse(for prompt: String) -> String {
        let lowered = prompt.lowercased()

        if lowered.contains("restaurant") || lowered.contains("food") {
            return """
            Based on your query, I'd recommend checking out these options:

            1. **Osteria Francescana** - Modena, Italy. Three Michelin stars, \
            known for innovative Italian cuisine.
            2. **Noma** - Copenhagen, Denmark. Famous for its New Nordic cuisine \
            and seasonal tasting menus.
            3. **El Celler de Can Roca** - Girona, Spain. A family-run restaurant \
            with creative Catalan dishes.

            Each offers a unique dining experience that celebrates local ingredients \
            and culinary tradition.
            """
        } else if lowered.contains("hello") || lowered.contains("hi") {
            return "Hello! I'm a mock AI assistant running in demo mode. " +
                "Ask me anything about restaurants, recipes, or food recommendations!"
        } else {
            return """
            This is a simulated response from the mock AI provider. \
            In production, this would be generated by Google Gemini \
            through Firebase AI Logic.

            Your prompt was: "\(prompt.prefix(100))"

            Try asking about restaurants or food for more interesting demo responses!
            """
        }
    }

    private func mockChatResponse(for message: String, history: [AIMessage]) -> String {
        let turnCount = history.count / 2 + 1
        let lowered = message.lowercased()

        if lowered.contains("thank") {
            return "You're welcome! Feel free to ask if you need anything else."
        } else if turnCount > 3 {
            return "Great conversation! In demo mode, I can simulate up to a few turns. " +
                "In production with Firebase AI, conversations can continue indefinitely."
        } else {
            return "That's an interesting follow-up! (Turn \(turnCount) of our conversation). " +
                "In production mode, the AI would provide a contextual response based " +
                "on our full conversation history."
        }
    }
}

// MARK: - Convenience Initializers

extension MockAIProvider {
    /// Creates a shared mock provider for previews.
    static let preview = MockAIProvider()
}
