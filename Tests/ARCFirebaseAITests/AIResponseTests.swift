//
//  AIResponseTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import Foundation
import Testing
@testable import ARCFirebaseAI

@Suite("AIResponse Tests") struct AIResponseTests {
    // MARK: - Initialisation

    @Test("Default finishReason is .stop") func defaultFinishReason() {
        // Given / When
        let response = makeSUT(content: "Hello")

        // Then
        #expect(response.finishReason == .stop)
    }

    @Test("Token counts default to nil") func defaultTokenCountsAreNil() {
        // Given / When
        let response = makeSUT(content: "Hello")

        // Then
        #expect(response.promptTokenCount == nil)
        #expect(response.candidatesTokenCount == nil)
        #expect(response.totalTokenCount == nil)
    }

    @Test("Stores token counts when provided") func storesTokenCounts() {
        // Given / When
        let response = AIResponse(content: "Test",
                                  finishReason: .stop,
                                  promptTokenCount: 10,
                                  candidatesTokenCount: 20,
                                  totalTokenCount: 30)

        // Then
        #expect(response.promptTokenCount == 10)
        #expect(response.candidatesTokenCount == 20)
        #expect(response.totalTokenCount == 30)
    }

    @Test("Stores content correctly") func storesContent() {
        // Given
        let content = "The generated text content"

        // When
        let response = makeSUT(content: content)

        // Then
        #expect(response.content == content)
    }

    // MARK: - Equatable

    @Test("Equal responses are equal") func equalityHolds() {
        // Given
        let lhs = AIResponse(content: "Hello", finishReason: .stop, promptTokenCount: 5)
        let rhs = AIResponse(content: "Hello", finishReason: .stop, promptTokenCount: 5)

        // Then
        #expect(lhs == rhs)
    }

    @Test("Responses with different content are not equal") func inequalityOnContent() {
        // Given
        let lhs = makeSUT(content: "Hello")
        let rhs = makeSUT(content: "World")

        // Then
        #expect(lhs != rhs)
    }

    @Test("Responses with different finishReason are not equal") func inequalityOnFinishReason() {
        // Given
        let lhs = AIResponse(content: "Hi", finishReason: .stop)
        let rhs = AIResponse(content: "Hi", finishReason: .maxTokens)

        // Then
        #expect(lhs != rhs)
    }

    // MARK: - FinishReason cases

    @Test("All FinishReason cases have expected raw values") func finishReasonRawValues() {
        // Given / Then
        let cases: [(AIResponse.FinishReason, String)] = [(.stop, "STOP"),
                                                          (.maxTokens, "MAX_TOKENS"),
                                                          (.safety, "SAFETY"),
                                                          (.recitation, "RECITATION"),
                                                          (.other, "OTHER"),
                                                          (.unknown, "UNKNOWN")]

        for (reason, expected) in cases {
            #expect(reason.rawValue == expected, "Expected rawValue '\(expected)' for \(reason)")
        }
    }

    @Test("FinishReason is Equatable") func finishReasonEquality() {
        #expect(AIResponse.FinishReason.stop == .stop)
        #expect(AIResponse.FinishReason.safety != .stop)
    }

    // MARK: - Helpers

    private func makeSUT(content: String = "") -> AIResponse {
        AIResponse(content: content)
    }
}
