//
//  StorageDemoView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 14/01/2026.
//

import ARCFirebaseAnalytics
import ARCFirebaseStorage
import SwiftUI

// MARK: - StorageDemoView

/// Demonstrates Firebase Storage operations: upload, download, and delete.
///
/// This view showcases the `StorageProviding` protocol with:
///
/// 1. **Data Upload**: Upload raw bytes with content type
/// 2. **URL Retrieval**: Get download URL for stored files
/// 3. **Data Download**: Download file contents to memory
/// 4. **File Deletion**: Remove files from storage
///
/// ## Key Concepts
///
/// - Storage paths work like file system paths (e.g., "images/photo.jpg")
/// - Content types (MIME types) help Firebase serve files correctly
/// - Download URLs can be shared or used in `AsyncImage`
/// - Large files should use streaming instead of in-memory download
struct StorageDemoView: View {
    // MARK: Private Properties

    /// Access to storage provider from environment.
    @Environment(\.storageProvider) private var storage

    /// Access to analytics for event tracking.
    @Environment(\.analyticsProvider) private var analytics

    /// The view model managing storage operations.
    @State private var viewModel: StorageDemoViewModel?

    // MARK: View

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    storageContent(viewModel)
                } else {
                    ProgressView("Initializing...")
                }
            }
            .navigationTitle("Storage Demo")
            .task {
                if viewModel == nil {
                    viewModel = StorageDemoViewModel(
                        storage: storage,
                        analytics: analytics
                    )
                }
            }
        }
    }
}

// MARK: - Private Views

extension StorageDemoView {
    @ViewBuilder
    private func storageContent(_ viewModel: StorageDemoViewModel) -> some View {
        List {
            // ==============================================================
            // Upload Section
            // ==============================================================
            Section {
                uploadDemoSection(viewModel)
            } header: {
                Text("Upload Demo")
            } footer: {
                Text("Uploads a sample text file to Firebase Storage")
            }

            // ==============================================================
            // Stored Files Section
            // ==============================================================
            if !viewModel.storedFiles.isEmpty {
                Section("Stored Files") {
                    ForEach(viewModel.storedFiles, id: \.path) { file in
                        StoredFileRow(file: file, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.deleteFile(viewModel.storedFiles[index])
                            }
                        }
                    }
                }
            }

            // ==============================================================
            // How It Works Section
            // ==============================================================
            Section("How It Works") {
                howItWorksContent
            }
        }
        .refreshable {
            // In a real app, you'd refresh the file list from Firebase
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    private func uploadDemoSection(_ viewModel: StorageDemoViewModel) -> some View {
        @Bindable var vm = viewModel

        return VStack(alignment: .leading, spacing: 12) {
            // File name input
            TextField("File name", text: $vm.fileName)
                .textFieldStyle(.roundedBorder)

            // Content input
            TextField("File content", text: $vm.fileContent, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3 ... 5)

            // Upload button
            Button {
                Task {
                    await viewModel.uploadTextFile()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                    Text("Upload File")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.fileName.isEmpty)
        }
        .padding(.vertical, 8)
    }

    private var howItWorksContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(
                icon: "arrow.up.doc",
                title: "Upload",
                description: "storage.upload(data:path:contentType:)"
            )

            InfoRow(
                icon: "link",
                title: "Get URL",
                description: "storage.downloadURL(path:)"
            )

            InfoRow(
                icon: "arrow.down.doc",
                title: "Download",
                description: "storage.download(path:)"
            )

            InfoRow(
                icon: "trash",
                title: "Delete",
                description: "storage.delete(path:)"
            )
        }
        .font(.caption)
    }
}

// MARK: - Supporting Views

struct StoredFileRow: View {
    let file: StoredFile
    let viewModel: StorageDemoViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.blue)

                Text(file.name)
                    .font(.headline)

                Spacer()

                Text(file.formattedSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let url = file.downloadURL {
                Text(url.absoluteString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text("Uploaded \(file.uploadDate, style: .relative) ago")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    await viewModel.deleteFile(file)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
            }
        }
    }
}

// MARK: - StoredFile Model

/// Represents a file stored in Firebase Storage.
struct StoredFile: Identifiable {
    let id = UUID()
    let path: String
    let name: String
    let size: Int
    let downloadURL: URL?
    let uploadDate: Date

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}

// MARK: - StorageDemoViewModel

/// ViewModel for the Storage demo screen.
///
/// This ViewModel demonstrates:
/// - Protocol-based storage dependency
/// - Async upload/download operations
/// - Local state management for UI
/// - Analytics event tracking
@MainActor
@Observable
final class StorageDemoViewModel {
    // MARK: Private Properties

    private let storage: any StorageProviding
    private let analytics: any AnalyticsProviding

    // MARK: Public State

    var fileName: String = "demo.txt"
    var fileContent: String = "Hello from ARCFirebase Example App!"
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var storedFiles: [StoredFile] = []

    // MARK: Initialization

    init(storage: any StorageProviding, analytics: any AnalyticsProviding) {
        self.storage = storage
        self.analytics = analytics
    }

    // MARK: Storage Operations

    /// Uploads a text file to Firebase Storage.
    ///
    /// This demonstrates the complete upload flow:
    /// 1. Convert string to Data
    /// 2. Generate storage path
    /// 3. Upload with content type
    /// 4. Track analytics event
    /// 5. Store result locally
    func uploadTextFile() async {
        guard !fileName.isEmpty else {
            errorMessage = "Please enter a file name"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Convert content to Data
            guard let data = fileContent.data(using: .utf8) else {
                errorMessage = "Failed to encode content"
                isLoading = false
                return
            }

            // Generate unique path to avoid overwrites
            let timestamp = Int(Date().timeIntervalSince1970)
            let path = "demo/\(timestamp)_\(fileName)"

            // Upload to Firebase Storage
            let downloadURL = try await storage.upload(
                data: data,
                path: path,
                contentType: "text/plain"
            )

            // Track analytics
            analytics.logEvent("file_uploaded", parameters: [
                "file_size": data.count,
                "content_type": "text/plain"
            ])

            // Add to local list
            let storedFile = StoredFile(
                path: path,
                name: fileName,
                size: data.count,
                downloadURL: downloadURL,
                uploadDate: Date()
            )
            storedFiles.insert(storedFile, at: 0)

            // Reset form
            fileContent = "Hello from ARCFirebase Example App!"

            print("✅ File uploaded: \(path)")

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Upload failed: \(error)")
        }

        isLoading = false
    }

    /// Deletes a file from Firebase Storage.
    func deleteFile(_ file: StoredFile) async {
        isLoading = true

        do {
            try await storage.delete(path: file.path)

            // Remove from local list
            storedFiles.removeAll { $0.id == file.id }

            analytics.logEvent("file_deleted")

            print("✅ File deleted: \(file.path)")

        } catch {
            errorMessage = error.localizedDescription
            print("❌ Delete failed: \(error)")
        }

        isLoading = false
    }

    /// Clears the error message.
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Previews

#Preview("Storage Demo - Empty") {
    StorageDemoView()
        .previewEnvironment()
}

#Preview("Storage Demo - With Files") {
    let view = StorageDemoView()

    return view
        .previewEnvironment()
}

#Preview("Storage Demo - Dark") {
    StorageDemoView()
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
