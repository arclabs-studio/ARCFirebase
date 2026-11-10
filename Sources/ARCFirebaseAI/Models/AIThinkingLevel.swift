//
//  AIThinkingLevel.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-10-09.
//

import Foundation

/// How much internal reasoning a Gemini 3.x model spends before answering.
///
/// Thinking tokens are billed as output, so the level is a cost control as much as a
/// quality one. `nil` on ``AIConfiguration/thinkingLevel`` keeps the model's own default
/// (Gemini 3.6 Flash: medium; 3.5 Flash-Lite: minimal).
///
/// Maps to `FirebaseAILogic.ThinkingConfig.ThinkingLevel`. Gemini 2.5 models do not
/// accept levels — they take a thinking *budget*, which this wrapper does not expose.
public enum AIThinkingLevel: String, Sendable, CaseIterable {
    /// The least reasoning the model supports — extraction and formatting tasks.
    case minimal
    /// Light reasoning.
    case low
    /// Balanced reasoning — the default for most Gemini 3.x Flash models.
    case medium
    /// The most reasoning — multi-step problems.
    case high
}
