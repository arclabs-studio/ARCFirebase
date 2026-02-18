//
//  FirebaseAIProviderTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Testing
@testable import ARCFirebaseAI

@Suite("FirebaseAIProvider Tests")
struct FirebaseAIProviderTests {
    // MARK: - Generate Content

    @Test("Mock provider generates content from prompt")
    func generateContent() async throws {
        // Given
        let sut = makeSUT()
        sut.mockResponse = AIResponse(content: "Generated text", finishReason: .stop)

        // When
        let response = try await sut.generateContent(prompt: "Hello", configuration: nil)

        // Then
        #expect(response.content == "Generated text")
        #expect(response.finishReason == .stop)
        #expect(sut.generateContentCallCount == 1)
        #expect(sut.lastPrompt == "Hello")
    }

    @Test("Mock provider generates content with system instruction")
    func generateContentWithSystemInstruction() async throws {
        // Given
        let sut = makeSUT()

        // When
        _ = try await sut.generateContent(
            prompt: "Describe this",
            systemInstruction: "You are a food critic",
            configuration: nil
        )

        // Then
        #expect(sut.generateContentWithSystemCallCount == 1)
        #expect(sut.lastPrompt == "Describe this")
        #expect(sut.lastSystemInstruction == "You are a food critic")
    }

    @Test("Mock provider generates structured content")
    func generateStructuredContent() async throws {
        // Given
        let sut = makeSUT()
        let schema = AISchema.object(properties: [
            "name": .string(),
            "rating": .integer()
        ])

        // When
        _ = try await sut.generateStructuredContent(
            prompt: "Extract restaurant info",
            responseSchema: schema,
            systemInstruction: nil,
            configuration: .structured
        )

        // Then
        #expect(sut.generateStructuredContentCallCount == 1)
        #expect(sut.lastConfiguration == .structured)
    }

    // MARK: - Streaming

    @Test("Mock provider streams content chunks")
    func streamContent() async throws {
        // Given
        let sut = makeSUT()
        sut.mockStreamChunks = ["Hello", " ", "World"]

        // When
        var result = ""
        let stream = sut.streamContent(prompt: "Tell me a story", configuration: nil)
        for try await chunk in stream {
            result += chunk
        }

        // Then
        #expect(result == "Hello World")
        #expect(sut.streamContentCallCount == 1)
    }

    @Test("Mock provider stream handles errors")
    func streamContentError() async throws {
        // Given
        let sut = makeSUT()
        sut.mockError = TestError.mockFailure

        // When/Then
        let stream = sut.streamContent(prompt: "Test", configuration: nil)
        do {
            for try await _ in stream {
                Issue.record("Expected error to be thrown")
            }
        } catch {
            #expect(error is TestError)
        }
    }

    // MARK: - Multi-Turn Chat

    @Test("Mock provider sends message with history")
    func sendMessage() async throws {
        // Given
        let sut = makeSUT()
        let history: [AIMessage] = [
            AIMessage(role: .user, content: "Hi"),
            AIMessage(role: .model, content: "Hello!")
        ]

        // When
        let response = try await sut.sendMessage(
            "How are you?",
            history: history,
            systemInstruction: nil,
            configuration: nil
        )

        // Then
        #expect(response.content == "Mock response")
        #expect(sut.sendMessageCallCount == 1)
        #expect(sut.lastMessage == "How are you?")
        #expect(sut.lastHistory?.count == 2)
    }

    // MARK: - Availability

    @Test("Mock provider reports availability")
    func isAvailable() async {
        // Given
        let sut = makeSUT()

        // When
        let available = await sut.isAvailable()

        // Then
        #expect(available == true)
        #expect(sut.isAvailableCallCount == 1)
    }

    @Test("Mock provider reports unavailable when configured")
    func isUnavailable() async {
        // Given
        let sut = makeSUT()
        sut.mockAvailable = false

        // When
        let available = await sut.isAvailable()

        // Then
        #expect(available == false)
    }

    // MARK: - Error Handling

    @Test("Mock provider throws errors when configured")
    func errorHandling() async throws {
        // Given
        let sut = makeSUT()
        sut.mockError = TestError.mockFailure

        // When/Then — generateContent
        do {
            _ = try await sut.generateContent(prompt: "Test", configuration: nil)
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }

        // When/Then — sendMessage
        do {
            _ = try await sut.sendMessage(
                "Test",
                history: [],
                systemInstruction: nil,
                configuration: nil
            )
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is TestError)
        }
    }

    @Test("Mock provider passes configuration correctly")
    func configurationPassthrough() async throws {
        // Given
        let sut = makeSUT()

        // When
        _ = try await sut.generateContent(prompt: "Test", configuration: .creative)

        // Then
        #expect(sut.lastConfiguration == .creative)
    }

    // MARK: - Reset

    @Test("Mock reset clears all state")
    func resetFunctionality() async throws {
        // Given
        let sut = makeSUT()
        _ = try await sut.generateContent(prompt: "Test", configuration: nil)
        _ = await sut.isAvailable()

        #expect(sut.generateContentCallCount == 1)
        #expect(sut.isAvailableCallCount == 1)
        #expect(sut.lastPrompt == "Test")

        // When
        sut.reset()

        // Then
        #expect(sut.generateContentCallCount == 0)
        #expect(sut.isAvailableCallCount == 0)
        #expect(sut.lastPrompt == nil)
    }

    // MARK: - Helpers

    private func makeSUT() -> MockAIProvider {
        MockAIProvider()
    }
}

// MARK: - Test Error

private enum TestError: Error {
    case mockFailure
}
