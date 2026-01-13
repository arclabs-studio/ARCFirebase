import ARCFirebaseAnalytics
import ARCFirebaseCrashlytics
import ARCFirebasePersistence
import SwiftUI

@MainActor
@Observable
final class ItemsViewModel {
    // MARK: - Dependencies

    private let analytics: any AnalyticsProviding
    private let repository: FirestoreRepository<Item>

    // MARK: - State

    var items: [Item] = []
    var isLoading: Bool = false
    var errorMessage: String?

    init(analytics: any AnalyticsProviding) {
        self.analytics = analytics

        do {
            repository = try FirestoreRepository(collectionPath: "items")
        } catch {
            repository = try! FirestoreRepository(collectionPath: "items")
            errorMessage = "Failed to initialize repository: \(error.localizedDescription)"
            CrashlyticsManager.shared.record(error: error)
        }
    }

    // MARK: - Load Items

    func loadItems() async {
        isLoading = true
        errorMessage = nil

        do {
            items = try await repository.fetchAll()

            // Track event
            analytics.logEvent("items_loaded", parameters: [
                "count": items.count
            ])

            print("✅ Loaded \(items.count) items")

        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.record(error: error)
            print("❌ Failed to load items: \(error)")
        }

        isLoading = false
    }

    // MARK: - Add Item

    func addItem(title: String, description: String, userId: String) async {
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        let item = Item.create(
            title: title,
            description: description,
            userId: userId
        )

        do {
            try await repository.save(item)

            // Track event
            analytics.logEvent("item_created", parameters: [
                "title_length": title.count
            ])

            // Reload items
            await loadItems()

            print("✅ Item added: \(item.title)")

        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.record(error: error)
            print("❌ Failed to add item: \(error)")
        }

        isLoading = false
    }

    // MARK: - Delete Item

    func deleteItem(_ item: Item) async {
        isLoading = true
        errorMessage = nil

        do {
            try await repository.delete(id: item.id)

            // Track event
            analytics.logEvent("item_deleted")

            // Remove from local array
            items.removeAll { $0.id == item.id }

            print("✅ Item deleted: \(item.title)")

        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.record(error: error)
            print("❌ Failed to delete item: \(error)")
        }

        isLoading = false
    }
}
