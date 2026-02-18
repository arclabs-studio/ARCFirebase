//
//  MockAIProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Foundation
@testable import ARCFirebaseAI

/// Mock AI provider for testing.
final class MockAIProvider: AIProviding, @unchecked Sendable {
    // MARK: - Mock State

    var mockResponse = AIResponse(content: "Mock response")
    var mockError: Error?
    var mockStreamChunks: [String] = ["Hello", " World"]
    var mockAvailable = true

    var generateContentCallCount = 0
    var generateContentWithSystemCallCount = 0
    var generateStructuredContentCallCount = 0
    var streamContentCallCount = 0
    var sendMessageCallCount = 0
    var isAvailableCallCount = 0

    var lastPrompt: String?
    var lastSystemInstruction: String?
    var lastConfiguration: AIConfiguration?
    var lastMessage: String?
    var lastHistory: [AIMessage]?

    // MARK: - AIProviding Implementation

    func generateContent(
        prompt: String,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        generateContentCallCount += 1
        lastPrompt = prompt
        lastConfiguration = configuration

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func generateContent(
        prompt: String,
        systemInstruction: String,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        generateContentWithSystemCallCount += 1
        lastPrompt = prompt
        lastSystemInstruction = systemInstruction
        lastConfiguration = configuration

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func generateStructuredContent(
        prompt: String,
        responseSchema _: AISchema,
        systemInstruction: String?,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        generateStructuredContentCallCount += 1
        lastPrompt = prompt
        lastSystemInstruction = systemInstruction
        lastConfiguration = configuration

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func streamContent(
        prompt: String,
        configuration: AIConfiguration?
    ) -> AsyncThrowingStream<String, Error> {
        streamContentCallCount += 1
        lastPrompt = prompt
        lastConfiguration = configuration

        let chunks = mockStreamChunks
        let error = mockError

        return AsyncThrowingStream { continuation in
            if let error {
                continuation.finish(throwing: error)
                return
            }

            for chunk in chunks {
                continuation.yield(chunk)
            }
            continuation.finish()
        }
    }

    func sendMessage(
        _ message: String,
        history: [AIMessage],
        systemInstruction: String?,
        configuration: AIConfiguration?
    ) async throws -> AIResponse {
        sendMessageCallCount += 1
        lastMessage = message
        lastHistory = history
        lastSystemInstruction = systemInstruction
        lastConfiguration = configuration

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func isAvailable() async -> Bool {
        isAvailableCallCount += 1
        return mockAvailable
    }

    // MARK: - Test Helpers

    func reset() {
        mockResponse = AIResponse(content: "Mock response")
        mockError = nil
        mockStreamChunks = ["Hello", " World"]
        mockAvailable = true

        generateContentCallCount = 0
        generateContentWithSystemCallCount = 0
        generateStructuredContentCallCount = 0
        streamContentCallCount = 0
        sendMessageCallCount = 0
        isAvailableCallCount = 0

        lastPrompt = nil
        lastSystemInstruction = nil
        lastConfiguration = nil
        lastMessage = nil
        lastHistory = nil
    }
}
