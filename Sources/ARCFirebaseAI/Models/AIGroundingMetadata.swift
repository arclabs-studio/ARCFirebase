//
//  AIGroundingMetadata.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 12/04/2026.
//

import Foundation

/// Metadata from Google Search grounding in Firebase AI responses.
///
/// Populated when grounding is enabled via `AIConfiguration.groundingEnabled`
/// and the provider supports it. Contains the search queries executed and web
/// sources cited in the grounded response.
///
/// When grounding is not requested or not supported, `AIResponse.groundingMetadata`
/// will be `nil`.
public struct AIGroundingMetadata: Sendable, Equatable {
    /// Search queries executed by the grounding tool.
    public let searchQueries: [String]

    /// Web sources cited in the grounded response.
    public let webSources: [AIWebSource]

    public init(searchQueries: [String] = [], webSources: [AIWebSource] = []) {
        self.searchQueries = searchQueries
        self.webSources = webSources
    }

    // MARK: - AIWebSource

    /// A single web source cited by the grounding search.
    public struct AIWebSource: Sendable, Equatable {
        /// Human-readable title of the source page.
        public let title: String

        /// URI of the source page.
        public let uri: String

        public init(title: String, uri: String) {
            self.title = title
            self.uri = uri
        }
    }
}
