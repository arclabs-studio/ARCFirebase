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
    /// Gemini 2.5 Pro — highest quality reasoning, slowest, most expensive.
    case pro25 = "gemini-2.5-pro"
    /// Gemini 2.5 Flash — primary model. Best balance of quality, latency, and cost.
    case flash25 = "gemini-2.5-flash"
    /// Gemini 2.5 Flash-Lite — fastest 2.5-tier model. Lower cost; reduced capability vs Flash.
    case flashLite25 = "gemini-2.5-flash-lite"
    /// Gemini 2.0 Flash — fallback model. More stable availability than 2.5 Flash.
    case flash20 = "gemini-2.0-flash"
    /// Gemini 2.0 Flash-Lite — lowest cost legacy fallback.
    case flashLite20 = "gemini-2.0-flash-lite"

    /// Human-readable name for logging and display.
    public var displayName: String {
        switch self {
        case .pro25: "Gemini 2.5 Pro"
        case .flash25: "Gemini 2.5 Flash"
        case .flashLite25: "Gemini 2.5 Flash-Lite"
        case .flash20: "Gemini 2.0 Flash"
        case .flashLite20: "Gemini 2.0 Flash-Lite"
        }
    }
}
