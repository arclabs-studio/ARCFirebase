//
//  MockAIProvider.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Foundation
import os
@testable import ARCFirebaseAI

/// Mock AI provider for testing.
final class MockAIProvider: AIProviding {
    private struct State {
        var mockResponse: AIResponse = .init(content: "Mock response")
        var mockError: Error?
        var mockStreamChunks: [String] = ["Hello", " World"]
        var mockAvailable: Bool = true
        var generateContentCallCount: Int = 0
        var generateContentWithSystemCallCount: Int = 0
        var generateStructuredContentCallCount: Int = 0
        var streamContentCallCount: Int = 0
        var sendMessageCallCount: Int = 0
        var isAvailableCallCount: Int = 0
        var lastPrompt: String?
        var lastSystemInstruction: String?
        var lastConfiguration: AIConfiguration?
        var lastMessage: String?
        var lastHistory: [AIMessage]?
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - Mock State

    var mockResponse: AIResponse {
        get { state.withLock { $0.mockResponse } }
        set { state.withLock { $0.mockResponse = newValue } }
    }

    var mockError: Error? {
        get { state.withLock { $0.mockError } }
        set { state.withLock { $0.mockError = newValue } }
    }

    var mockStreamChunks: [String] {
        get { state.withLock { $0.mockStreamChunks } }
        set { state.withLock { $0.mockStreamChunks = newValue } }
    }

    var mockAvailable: Bool {
        get { state.withLock { $0.mockAvailable } }
        set { state.withLock { $0.mockAvailable = newValue } }
    }

    var generateContentCallCount: Int {
        state.withLock { $0.generateContentCallCount }
    }

    var generateContentWithSystemCallCount: Int {
        state.withLock { $0.generateContentWithSystemCallCount }
    }

    var generateStructuredContentCallCount: Int {
        state.withLock { $0.generateStructuredContentCallCount }
    }

    var streamContentCallCount: Int {
        state.withLock { $0.streamContentCallCount }
    }

    var sendMessageCallCount: Int {
        state.withLock { $0.sendMessageCallCount }
    }

    var isAvailableCallCount: Int {
        state.withLock { $0.isAvailableCallCount }
    }

    var lastPrompt: String? {
        state.withLock { $0.lastPrompt }
    }

    var lastSystemInstruction: String? {
        state.withLock { $0.lastSystemInstruction }
    }

    var lastConfiguration: AIConfiguration? {
        state.withLock { $0.lastConfiguration }
    }

    var lastMessage: String? {
        state.withLock { $0.lastMessage }
    }

    var lastHistory: [AIMessage]? {
        state.withLock { $0.lastHistory }
    }

    // MARK: - AIProviding Implementation

    func generateContent(prompt: String,
                         configuration: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.generateContentCallCount += 1 }
        state.withLock { $0.lastPrompt = prompt }
        state.withLock { $0.lastConfiguration = configuration }

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func generateContent(prompt: String,
                         systemInstruction: String,
                         configuration: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.generateContentWithSystemCallCount += 1 }
        state.withLock { $0.lastPrompt = prompt }
        state.withLock { $0.lastSystemInstruction = systemInstruction }
        state.withLock { $0.lastConfiguration = configuration }

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func generateStructuredContent(prompt: String,
                                   responseSchema _: AISchema,
                                   systemInstruction: String?,
                                   configuration: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.generateStructuredContentCallCount += 1 }
        state.withLock { $0.lastPrompt = prompt }
        state.withLock { $0.lastSystemInstruction = systemInstruction }
        state.withLock { $0.lastConfiguration = configuration }

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func streamContent(prompt: String,
                       configuration: AIConfiguration?) -> AsyncThrowingStream<String, Error> {
        state.withLock { $0.streamContentCallCount += 1 }
        state.withLock { $0.lastPrompt = prompt }
        state.withLock { $0.lastConfiguration = configuration }

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

    func sendMessage(_ message: String,
                     history: [AIMessage],
                     systemInstruction: String?,
                     configuration: AIConfiguration?) async throws -> AIResponse {
        state.withLock { $0.sendMessageCallCount += 1 }
        state.withLock { $0.lastMessage = message }
        state.withLock { $0.lastHistory = history }
        state.withLock { $0.lastSystemInstruction = systemInstruction }
        state.withLock { $0.lastConfiguration = configuration }

        if let error = mockError {
            throw error
        }

        return mockResponse
    }

    func isAvailable() async -> Bool {
        state.withLock { $0.isAvailableCallCount += 1 }
        return mockAvailable
    }

    // MARK: - Test Helpers

    func reset() {
        state.withLock { $0.mockResponse = AIResponse(content: "Mock response") }
        state.withLock { $0.mockError = nil }
        state.withLock { $0.mockStreamChunks = ["Hello", " World"] }
        state.withLock { $0.mockAvailable = true }

        state.withLock { $0.generateContentCallCount = 0 }
        state.withLock { $0.generateContentWithSystemCallCount = 0 }
        state.withLock { $0.generateStructuredContentCallCount = 0 }
        state.withLock { $0.streamContentCallCount = 0 }
        state.withLock { $0.sendMessageCallCount = 0 }
        state.withLock { $0.isAvailableCallCount = 0 }

        state.withLock { $0.lastPrompt = nil }
        state.withLock { $0.lastSystemInstruction = nil }
        state.withLock { $0.lastConfiguration = nil }
        state.withLock { $0.lastMessage = nil }
        state.withLock { $0.lastHistory = nil }
    }
}
