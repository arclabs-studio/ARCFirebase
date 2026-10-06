//
//  AISafetySetting.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-09-01.
//

import Foundation

/// A provider-agnostic safety filter setting for AI content generation.
///
/// Pass an array of settings via ``AIConfiguration/safetySettings`` to control
/// the harm-category thresholds the underlying provider enforces on generated
/// content. Mapped to `FirebaseAI.SafetySetting` at the provider boundary.
///
/// ## Usage
///
/// ```swift
/// let config = AIConfiguration(
///     temperature: 0.4,
///     safetySettings: AISafetySetting.standardModeration
/// )
/// ```
public struct AISafetySetting: Sendable, Hashable {
    /// The category of potentially harmful content the setting applies to.
    public enum Category: String, CaseIterable, Sendable {
        case harassment
        case hateSpeech
        case sexuallyExplicit
        case dangerousContent
    }

    /// The threshold at and beyond which content in the category is blocked.
    public enum Threshold: String, CaseIterable, Sendable {
        /// Block content with low, medium or high harm probability.
        case blockLowAndAbove
        /// Block content with medium or high harm probability.
        case blockMediumAndAbove
        /// Block only content with high harm probability.
        case blockOnlyHigh
        /// Allow all content in the category.
        case blockNone
        /// Turn the safety filter off for the category.
        case off
    }

    /// The harm category this setting applies to.
    public let category: Category

    /// The blocking threshold for the category.
    public let threshold: Threshold

    /// Creates a safety setting for one harm category.
    ///
    /// - Parameters:
    ///   - category: The harm category the setting applies to.
    ///   - threshold: The threshold at and beyond which content is blocked.
    public init(category: Category, threshold: Threshold) {
        self.category = category
        self.threshold = threshold
    }

    /// Every category at ``Threshold/blockMediumAndAbove`` — the recommended
    /// moderation baseline for user-facing features.
    public static let standardModeration: [AISafetySetting] = Category.allCases.map {
        AISafetySetting(category: $0, threshold: .blockMediumAndAbove)
    }
}
