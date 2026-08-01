//
//  AISchema.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import FirebaseAI

/// A type alias for Firebase AI `Schema`, re-exported for convenience.
///
/// Use this type when defining response schemas for structured content generation,
/// without needing to import `FirebaseAI` directly.
///
/// ```swift
/// let schema = AISchema.object(properties: [
///     "name": .string(),
///     "rating": .integer()
/// ])
///
/// let response = try await ai.generateStructuredContent(
///     prompt: "Describe a restaurant",
///     responseSchema: schema
/// )
/// ```
public typealias AISchema = Schema
