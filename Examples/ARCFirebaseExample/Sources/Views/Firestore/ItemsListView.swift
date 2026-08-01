//
//  ItemsListView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import SwiftUI

// MARK: - ItemsListView

/// Demonstrates Firestore CRUD operations with `FirestoreRepository`.
///
/// This view showcases the **Repository Pattern** for data access:
///
/// 1. **fetchAll()** - Load all items from collection
/// 2. **save(_:)** - Create a new document
/// 3. **update(_:)** - Modify an existing document
/// 4. **delete(id:)** - Remove a document
///
/// ## Key Concepts
///
/// - `FirestoreDocument` protocol for automatic timestamps
/// - Generic `FirestoreRepository<T>` for type-safe operations
/// - Offline support via Firebase's built-in caching
/// - Real-time updates (not shown in this demo)
struct ItemsListView: View {
    // MARK: Private Properties

    /// Access to shared auth state for user ID.
    @Environment(AuthViewModel.self) private var authViewModel

    /// Access to analytics provider from environment.
    @Environment(\.analyticsProvider) private var analytics

    /// The view model managing item operations.
    @State private var viewModel: ItemsViewModel?

    /// Controls presentation of add item sheet.
    @State private var showAddItem = false

    // MARK: View

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    itemsContent(viewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Items")
            .toolbar {
                toolbarContent
            }
            .task {
                // ================================================================
                // Lazy ViewModel Initialization
                // ================================================================
                // Initialize ViewModel with analytics dependency.
                // Loading happens automatically in onAppear.

                if viewModel == nil {
                    viewModel = ItemsViewModel(analytics: analytics)
                }
                await viewModel?.loadItems()
            }
            .sheet(isPresented: $showAddItem) {
                if let viewModel {
                    AddItemView(viewModel: viewModel)
                        .environment(authViewModel)
                }
            }
            .alert("Error", isPresented: .constant(viewModel?.errorMessage != nil)) {
                Button("OK") {
                    viewModel?.clearError()
                }
            } message: {
                if let error = viewModel?.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Private Views

extension ItemsListView {
    @ViewBuilder
    private func itemsContent(_ viewModel: ItemsViewModel) -> some View {
        if viewModel.isLoading, viewModel.items.isEmpty {
            // ================================================================
            // Loading State
            // ================================================================
            // Show loading only on initial load, not on refresh.
            ProgressView("Loading items...")
        } else if viewModel.items.isEmpty {
            // ================================================================
            // Empty State
            // ================================================================
            // ContentUnavailableView provides consistent empty state design.
            ContentUnavailableView(
                "No Items",
                systemImage: "tray",
                description: Text("Tap + to add your first item")
            )
        } else {
            // ================================================================
            // Items List
            // ================================================================
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        ItemRowView(item: item)
                    }
                }
                .onDelete { indexSet in
                    Task {
                        for index in indexSet {
                            await viewModel.deleteItem(viewModel.items[index])
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.loadItems()
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        // Add button
        ToolbarItem(placement: .primaryAction) {
            Button {
                showAddItem = true
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add new item")
        }

        // Refresh button
        ToolbarItem(placement: .secondaryAction) {
            Button {
                Task {
                    await viewModel?.loadItems()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(viewModel?.isLoading ?? true)
            .accessibilityLabel("Refresh items")
        }
    }
}

// MARK: - ItemRowView

/// A row view displaying item summary information.
///
/// Design principles:
/// - Title prominently displayed
/// - Description truncated to 2 lines
/// - Relative date for recency context
struct ItemRowView: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)

            Text(item.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(item.createdAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ItemDetailView

/// Detail view showing all item properties.
///
/// Demonstrates displaying `FirestoreDocument` metadata:
/// - createdAt: When the document was created
/// - updatedAt: When it was last modified
/// - userId: Owner identification for access control
struct ItemDetailView: View {
    let item: Item

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Title", value: item.title)

                Text(item.description)
                    .font(.body)
            }

            Section("Metadata") {
                LabeledContent("Created") {
                    Text(item.createdAt, style: .date)
                    Text(item.createdAt, style: .time)
                }

                LabeledContent("Updated") {
                    Text(item.updatedAt, style: .date)
                    Text(item.updatedAt, style: .time)
                }

                LabeledContent("Item ID") {
                    Text(item.id)
                        .font(.caption)
                        .fontDesign(.monospaced)
                }

                LabeledContent("User ID") {
                    Text(String(item.userId.prefix(12)) + "...")
                        .font(.caption)
                        .fontDesign(.monospaced)
                }
            }
        }
        .navigationTitle("Item Details")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - AddItemView

/// Form for creating new items.
///
/// Demonstrates:
/// - Form validation before submission
/// - User ID association for ownership
/// - Dismissing sheet on success
struct AddItemView: View {
    // MARK: Private Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Bindable var viewModel: ItemsViewModel

    @State private var title = ""
    @State private var description = ""

    // MARK: View

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Information") {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Item title")

                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3 ... 6)
                        .accessibilityLabel("Item description")
                }

                Section {
                    Button("Add Item") {
                        Task {
                            guard let userId = authViewModel.currentUser?.id else {
                                return
                            }
                            await viewModel.addItem(
                                title: title,
                                description: description,
                                userId: userId
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || viewModel.isLoading)
                } footer: {
                    Text("Items are stored in Firestore and associated with your user ID")
                }
            }
            .navigationTitle("Add Item")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - Previews

#Preview("Items List - Empty") {
    let mockAuth = MockAuthProvider.authenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.mockAuthenticate()

    return ItemsListView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Items List - With Items") {
    let mockAuth = MockAuthProvider.authenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.mockAuthenticate()

    return ItemsListView()
        .environment(viewModel)
        .previewEnvironment()
}

#Preview("Item Row") {
    List {
        ItemRowView(item: SampleData.singleItem)
        ItemRowView(item: SampleData.items[1])
    }
}

#Preview("Item Detail") {
    NavigationStack {
        ItemDetailView(item: SampleData.singleItem)
    }
}

#Preview("Items List - Dark Mode") {
    let mockAuth = MockAuthProvider.authenticated
    let viewModel = AuthViewModel(
        auth: mockAuth,
        analytics: MockAnalyticsProvider.preview
    )
    viewModel.mockAuthenticate()

    return ItemsListView()
        .environment(viewModel)
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
