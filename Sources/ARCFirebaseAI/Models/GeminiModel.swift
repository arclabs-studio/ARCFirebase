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
/// let provider = try FirebaseAIProvider(model: .flash36)
/// let fallback = try FirebaseAIProvider(model: .flashLite35)
/// ```
public enum GeminiModel: String, Sendable {
    /// Gemini 3.6 Flash — primary model. Official replacement for 2.5/2.0 Flash (GA 2026-07-21).
    case flash36 = "gemini-3.6-flash"
    /// Gemini 3.5 Flash — higher-capability 3.5-tier model.
    case flash35 = "gemini-3.5-flash"
    /// Gemini 3.5 Flash-Lite — high-volume, cost-sensitive workhorse (GA 2026-07-21).
    case flashLite35 = "gemini-3.5-flash-lite"
    /// Gemini 3.1 Flash-Lite — lowest-cost 3.x model.
    case flashLite31 = "gemini-3.1-flash-lite"

    /// Human-readable name for logging and display.
    public var displayName: String {
        switch self {
        case .flash36: "Gemini 3.6 Flash"
        case .flash35: "Gemini 3.5 Flash"
        case .flashLite35: "Gemini 3.5 Flash-Lite"
        case .flashLite31: "Gemini 3.1 Flash-Lite"
        }
    }
}
