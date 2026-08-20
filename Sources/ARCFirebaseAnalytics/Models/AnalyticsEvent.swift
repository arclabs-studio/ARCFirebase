//
//  AnalyticsEvent.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 2026-01-13.
//

import Foundation

/// Common analytics event names for ARC Labs Studio apps.
///
/// Use these predefined events for consistency across apps.
///
/// ```swift
/// AnalyticsManager.shared.logEvent(
///     AnalyticsEvent.itemViewed,
///     parameters: ["item_id": "abc123"]
/// )
/// ```
public enum AnalyticsEvent {
    // MARK: - E-commerce

    /// User viewed an item (restaurant, book, product, etc.)
    public static let itemViewed = "item_viewed"

    /// User added an item to favorites
    public static let itemFavorited = "item_favorited"

    /// User removed an item from favorites
    public static let itemUnfavorited = "item_unfavorited"

    /// User shared an item
    public static let itemShared = "item_shared"

    // MARK: - Search

    /// User performed a search
    public static let searchPerformed = "search_performed"

    /// User applied a filter
    public static let filterApplied = "filter_applied"

    // MARK: - User Actions

    /// User completed onboarding
    public static let onboardingCompleted = "onboarding_completed"

    /// User opened the app
    public static let appOpened = "app_opened"

    // MARK: - Errors

    /// An error occurred
    public static let errorOccurred = "error_occurred"
}
