//
//  AIMessageTests.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Testing
@testable import ARCFirebaseAI

@Suite("AIMessage Tests") struct AIMessageTests {
    // MARK: - Initialization

    @Test("User message initializes correctly") func userMessageInit() {
        // Given/When
        let sut = AIMessage(role: .user, content: "Hello")

        // Then
        #expect(sut.role == .user)
        #expect(sut.content == "Hello")
    }

    @Test("Model message initializes correctly") func modelMessageInit() {
        // Given/When
        let sut = AIMessage(role: .model, content: "Hi there!")

        // Then
        #expect(sut.role == .model)
        #expect(sut.content == "Hi there!")
    }

    // MARK: - Role

    @Test("Role raw values are correct") func roleRawValues() {
        #expect(AIMessage.Role.user.rawValue == "user")
        #expect(AIMessage.Role.model.rawValue == "model")
    }

    // MARK: - Equatable

    @Test("Messages with same values are equal") func equality() {
        // Given
        let message1 = AIMessage(role: .user, content: "Hello")
        let message2 = AIMessage(role: .user, content: "Hello")

        // Then
        #expect(message1 == message2)
    }

    @Test("Messages with different content are not equal") func contentInequality() {
        // Given
        let message1 = AIMessage(role: .user, content: "Hello")
        let message2 = AIMessage(role: .user, content: "World")

        // Then
        #expect(message1 != message2)
    }

    @Test("Messages with different roles are not equal") func roleInequality() {
        // Given
        let message1 = AIMessage(role: .user, content: "Hello")
        let message2 = AIMessage(role: .model, content: "Hello")

        // Then
        #expect(message1 != message2)
    }

    // MARK: - Conversation History

    @Test("Messages can form a conversation history") func conversationHistory() {
        // Given/When
        let history: [AIMessage] = [AIMessage(role: .user, content: "What's a good restaurant?"),
                                    AIMessage(role: .model, content: "I'd recommend Osteria Francescana."),
                                    AIMessage(role: .user, content: "What about Japanese?"),
                                    AIMessage(role: .model, content: "Try Sukiyabashi Jiro.")]

        // Then
        #expect(history.count == 4)
        #expect(history[0].role == .user)
        #expect(history[1].role == .model)
        #expect(history[2].role == .user)
        #expect(history[3].role == .model)
    }
}
