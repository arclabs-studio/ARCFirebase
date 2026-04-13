//
//  GeminiModel.swift
//  ARCFirebase
//

import Foundation

/// Gemini model identifiers available through Firebase AI.
///
/// Use with ``FirebaseAIProvider`` to select the model for content generation.
///
/// ```swift
/// let provider = try FirebaseAIProvider(model: .flash25)
/// let fallback = try FirebaseAIProvider(model: .flash20)
/// ```
public enum GeminiModel: String, Sendable, CaseIterable {
    /// Gemini 2.5 Flash — primary model. Best quality; may be overloaded during high demand.
    case flash25 = "gemini-2.5-flash"
    /// Gemini 2.0 Flash — fallback model. More stable availability.
    case flash20 = "gemini-2.0-flash"

    /// Human-readable name for logging and display.
    public var displayName: String {
        switch self {
        case .flash25: "Gemini 2.5 Flash"
        case .flash20: "Gemini 2.0 Flash"
        }
    }
}
