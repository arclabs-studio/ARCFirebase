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

/// Common analytics parameter names.
public enum AnalyticsParameter {
    /// Item ID
    public static let itemID = "item_id"

    /// Item name
    public static let itemName = "item_name"

    /// Item category
    public static let itemCategory = "item_category"

    /// Search query
    public static let searchQuery = "search_query"

    /// Filter type
    public static let filterType = "filter_type"

    /// Error message
    public static let errorMessage = "error_message"

    /// Screen name
    public static let screenName = "screen_name"
}
