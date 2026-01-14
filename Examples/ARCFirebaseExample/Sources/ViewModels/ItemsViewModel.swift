//
//  ItemsViewModel.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics
import ARCFirebasePersistence
import Foundation

// MARK: - ItemsViewModel

/// ViewModel responsible for Firestore CRUD operations on items.
///
/// This ViewModel demonstrates the **Repository Pattern** with Firebase:
///
/// 1. **Generic Repository**: `FirestoreRepository<Item>` provides type-safe CRUD
/// 2. **Protocol-based**: Repository conforms to `Repository` protocol for testing
/// 3. **Error Handling**: Graceful error recovery with user-friendly messages
/// 4. **Analytics Integration**: Tracks all data operations for insights
///
/// ## Repository Pattern Benefits
///
/// - **Abstraction**: ViewModels don't know about Firebase internals
/// - **Testability**: Can swap repository with mock for testing
/// - **Type Safety**: Generic constraints ensure correct document types
/// - **Consistency**: Standard CRUD interface across all collections
///
/// ## Usage
///
/// ```swift
/// let viewModel = ItemsViewModel(analytics: analyticsProvider)
///
/// // Load items
/// await viewModel.loadItems()
///
/// // Add item
/// await viewModel.addItem(title: "New Item", description: "Details", userId: userId)
///
/// // Delete item
/// await viewModel.deleteItem(item)
/// ```
///
/// - Note: In this demo, we use in-memory storage to avoid Firebase configuration.
///         In production, use `FirestoreRepository<Item>` for real persistence.
@MainActor
@Observable
final class ItemsViewModel {
    // MARK: Private Properties

    /// Analytics provider for event tracking.
    private let analytics: any AnalyticsProviding

    /// Crashlytics provider for error recording.
    private let crashlytics: any CrashlyticsProviding

    // MARK: Public State

    /// All loaded items.
    private(set) var items: [Item] = []

    /// Indicates if a data operation is in progress.
    private(set) var isLoading: Bool = false

    /// Current error message to display.
    var errorMessage: String?

    // MARK: Initialization

    /// Creates an ItemsViewModel with analytics dependency.
    ///
    /// - Parameters:
    ///   - analytics: Analytics provider for event tracking.
    ///   - crashlytics: Crashlytics provider for error recording.
    init(
        analytics: any AnalyticsProviding,
        crashlytics: any CrashlyticsProviding = MockCrashlyticsProvider()
    ) {
        self.analytics = analytics
        self.crashlytics = crashlytics
    }

    // MARK: CRUD Operations

    /// Loads all items.
    ///
    /// In production with Firebase configured, this would use:
    /// ```swift
    /// let repo = try FirestoreRepository<Item>(collectionPath: "items")
    /// items = try await repo.fetchAll()
    /// ```
    func loadItems() async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(500))

        // In this demo, we use sample data
        // In production, uncomment the repository code below:
        //
        // do {
        //     let repo = try FirestoreRepository<Item>(collectionPath: "items")
        //     items = try await repo.fetchAll()
        // } catch {
        //     handleError(error, context: "loading items")
        // }

        analytics.logEvent("items_loaded", parameters: [
            "count": items.count
        ])

        print("✅ Loaded \(items.count) items")
        isLoading = false
    }

    /// Creates a new item.
    ///
    /// In production with Firebase configured, this would use:
    /// ```swift
    /// let repo = try FirestoreRepository<Item>(collectionPath: "items")
    /// try await repo.save(item)
    /// ```
    ///
    /// - Parameters:
    ///   - title: The item title (required).
    ///   - description: The item description.
    ///   - userId: The owner's user ID for access control.
    func addItem(title: String, description: String, userId: String) async {
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        // Create Item with timestamps
        let item = Item.create(
            title: title,
            description: description,
            userId: userId
        )

        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(300))

        // In this demo, add to local array
        // In production, uncomment the repository code below:
        //
        // do {
        //     let repo = try FirestoreRepository<Item>(collectionPath: "items")
        //     try await repo.save(item)
        // } catch {
        //     handleError(error, context: "adding item")
        //     return
        // }

        items.insert(item, at: 0)

        analytics.logEvent("item_created", parameters: [
            "title_length": title.count
        ])

        print("✅ Item added: \(item.title)")
        isLoading = false
    }

    /// Deletes an item.
    ///
    /// In production with Firebase configured, this would use:
    /// ```swift
    /// let repo = try FirestoreRepository<Item>(collectionPath: "items")
    /// try await repo.delete(id: item.id)
    /// ```
    ///
    /// - Parameter item: The item to delete.
    func deleteItem(_ item: Item) async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(for: .milliseconds(200))

        // In this demo, remove from local array
        // In production, uncomment the repository code below:
        //
        // do {
        //     let repo = try FirestoreRepository<Item>(collectionPath: "items")
        //     try await repo.delete(id: item.id)
        // } catch {
        //     handleError(error, context: "deleting item")
        //     return
        // }

        items.removeAll { $0.id == item.id }

        analytics.logEvent("item_deleted")

        print("✅ Item deleted: \(item.title)")
        isLoading = false
    }

    /// Clears the current error message.
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Private Helpers

extension ItemsViewModel {
    /// Handles errors with logging and user feedback.
    private func handleError(_ error: Error, context: String) {
        errorMessage = "Failed to \(context). Please try again."
        crashlytics.record(error: error)
        print("❌ Error \(context): \(error)")
    }
}
