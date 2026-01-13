import SwiftUI

struct ItemsListView: View {

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel = ItemsViewModel()
    @State private var showAddItem = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView("Loading items...")
                } else if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "tray",
                        description: Text("Tap + to add your first item")
                    )
                } else {
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
                }
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        Task {
                            await viewModel.loadItems()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                await viewModel.loadItems()
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView(viewModel: viewModel)
                    .environment(authViewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

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

struct ItemDetailView: View {

    let item: Item

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Title", value: item.title)
                LabeledContent("Description", value: item.description)
            }

            Section("Metadata") {
                LabeledContent("Created", value: item.createdAt.formatted())
                LabeledContent("Updated", value: item.updatedAt.formatted())
                LabeledContent("User ID", value: item.userId)
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddItemView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var authViewModel
    @Bindable var viewModel: ItemsViewModel

    @State private var title = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Information") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button("Add Item") {
                        Task {
                            guard let userId = authViewModel.currentUser?.id else { return }
                            await viewModel.addItem(
                                title: title,
                                description: description,
                                userId: userId
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    ItemsListView()
        .environment(AuthViewModel())
}
