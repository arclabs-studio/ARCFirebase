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

    /// Gemini 2.5 Pro — deprecated. Retires 2026-10-16 on the Gemini Developer API.
    @available(*, deprecated, message: "Retires 2026-10-16. Migrate to a Gemini 3.x model.")
    case pro25 = "gemini-2.5-pro"
    /// Gemini 2.5 Flash — deprecated. Retires 2026-10-16; free tier capped at ~20 requests/day.
    @available(*, deprecated, message: "Retires 2026-10-16. Use .flash36 instead.")
    case flash25 = "gemini-2.5-flash"
    /// Gemini 2.5 Flash-Lite — deprecated. Retires 2026-10-16.
    @available(*, deprecated, message: "Retires 2026-10-16. Use .flashLite35 instead.")
    case flashLite25 = "gemini-2.5-flash-lite"
    /// Gemini 2.0 Flash — RETIRED 2026-06-01 on the Gemini Developer API. Calls always fail.
    @available(*, deprecated, message: "Retired 2026-06-01. Use .flash36 instead.")
    case flash20 = "gemini-2.0-flash"
    /// Gemini 2.0 Flash-Lite — RETIRED 2026-06-01 on the Gemini Developer API. Calls always fail.
    @available(*, deprecated, message: "Retired 2026-06-01. Use .flashLite35 instead.")
    case flashLite20 = "gemini-2.0-flash-lite"

    /// Human-readable name for logging and display.
    public var displayName: String {
        switch self {
        case .flash36: "Gemini 3.6 Flash"
        case .flash35: "Gemini 3.5 Flash"
        case .flashLite35: "Gemini 3.5 Flash-Lite"
        case .flashLite31: "Gemini 3.1 Flash-Lite"
        case .pro25: "Gemini 2.5 Pro"
        case .flash25: "Gemini 2.5 Flash"
        case .flashLite25: "Gemini 2.5 Flash-Lite"
        case .flash20: "Gemini 2.0 Flash"
        case .flashLite20: "Gemini 2.0 Flash-Lite"
        }
    }
}
