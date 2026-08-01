//
//  AIMessage.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-17.
//

import Foundation

/// A message in a multi-turn AI conversation.
///
/// Use this to build conversation history for chat-based interactions.
///
/// ## Usage
///
/// ```swift
/// let history: [AIMessage] = [
///     AIMessage(role: .user, content: "What's the best Italian restaurant?"),
///     AIMessage(role: .model, content: "I'd recommend Osteria Francescana..."),
/// ]
///
/// let response = try await ai.sendMessage(
///     "What about Japanese food?",
///     history: history
/// )
/// ```
///
/// ## Topics
///
/// ### Properties
/// - ``role``
/// - ``content``
///
/// ### Role
/// - ``Role``
public struct AIMessage: Sendable, Equatable {
    /// The role of the message sender.
    public let role: Role

    /// The text content of the message.
    public let content: String

    /// Creates a message with a role and content.
    ///
    /// - Parameters:
    ///   - role: The role of the sender (`.user` or `.model`).
    ///   - content: The text content of the message.
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }

    /// The role of a message participant.
    public enum Role: String, Sendable, Equatable {
        /// A message from the user.
        case user

        /// A message from the AI model.
        case model
    }
}
