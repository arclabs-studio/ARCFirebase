//
//  AIChatView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import ARCFirebaseAI
import ARCFirebaseAnalytics
import SwiftUI

// MARK: - AIChatView

/// Demonstrates Firebase AI (Gemini) content generation and streaming.
///
/// This view showcases the `AIProviding` protocol with:
///
/// 1. **Simple Generation**: One-shot content generation from a prompt
/// 2. **Streaming**: Real-time word-by-word response display
/// 3. **Multi-Turn Chat**: Conversation with context history
/// 4. **Configuration Presets**: Creative, factual, and structured modes
///
/// ## Key Concepts
///
/// - Firebase proxies the Gemini API so API keys never touch the client
/// - `AIProviding` protocol enables mock providers for previews/tests
/// - `AIConfiguration` presets control creativity vs precision
/// - `AIMessage` history enables multi-turn conversations
struct AIChatView: View {
    // MARK: Private Properties

    /// Access to AI provider from environment.
    @Environment(\.aiProvider) private var ai

    /// Access to analytics for event tracking.
    @Environment(\.analyticsProvider) private var analytics

    /// The view model managing AI operations.
    @State private var viewModel: AIChatViewModel?

    // MARK: View

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    chatContent(viewModel)
                } else {
                    ProgressView("Initializing...")
                }
            }
            .navigationTitle("AI Chat")
            .task {
                if viewModel == nil {
                    viewModel = AIChatViewModel(
                        ai: ai,
                        analytics: analytics
                    )
                }
            }
        }
    }
}

// MARK: - Private Views

extension AIChatView {
    @ViewBuilder
    private func chatContent(_ viewModel: AIChatViewModel) -> some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            // ==============================================================
            // Messages List
            // ==============================================================
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(
                            Array(viewModel.messages.enumerated()),
                            id: \.offset
                        ) { index, message in
                            MessageBubble(message: message)
                                .id(index)
                        }

                        // Streaming indicator
                        if viewModel.isStreaming {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Generating...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.leading, 16)
                            .id("streaming")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.count - 1, anchor: .bottom)
                    }
                }
            }

            Divider()

            // ==============================================================
            // Mode Picker
            // ==============================================================
            Picker("Mode", selection: $vm.selectedMode) {
                ForEach(AIChatViewModel.ChatMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            // ==============================================================
            // Input Area
            // ==============================================================
            HStack(spacing: 12) {
                TextField("Ask something...", text: $vm.inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1 ... 4)
                    .onSubmit {
                        Task { await viewModel.send() }
                    }

                Button {
                    Task { await viewModel.send() }
                } label: {
                    Image(systemName: viewModel.isLoading ? "hourglass" : "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(viewModel.isLoading || viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Clear Chat", systemImage: "trash") {
                        viewModel.clearChat()
                    }

                    Divider()

                    Section("Configuration") {
                        Button("Default") { viewModel.configuration = .default }
                        Button("Creative") { viewModel.configuration = .creative }
                        Button("Factual") { viewModel.configuration = .factual }
                    }

                    Section("Info") {
                        if let tokens = viewModel.lastTokenCount {
                            Text("Last response: \(tokens) tokens")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - MessageBubble

/// A chat message bubble matching the sender's role.
struct MessageBubble: View {
    let message: AIMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.role == .user ? "You" : "Gemini")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(message.content)
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user
                            ? Color.accentColor.opacity(0.15)
                            : Color(.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if message.role == .model { Spacer(minLength: 60) }
        }
    }
}

// MARK: - AIChatViewModel

/// ViewModel for the AI Chat demo screen.
///
/// Demonstrates:
/// - Protocol-based AI dependency
/// - Three generation modes (generate, stream, chat)
/// - Configuration presets
/// - Analytics event tracking
@MainActor
@Observable
final class AIChatViewModel {
    // MARK: Types

    enum ChatMode: String, CaseIterable, Identifiable {
        case generate = "Generate"
        case stream = "Stream"
        case chat = "Chat"

        var id: String { rawValue }
    }

    // MARK: Private Properties

    private let ai: any AIProviding
    private let analytics: any AnalyticsProviding
    private var chatHistory: [AIMessage] = []

    // MARK: Public State

    var inputText: String = ""
    var selectedMode: ChatMode = .stream
    var configuration: AIConfiguration? = .default
    private(set) var messages: [AIMessage] = []
    private(set) var isLoading: Bool = false
    private(set) var isStreaming: Bool = false
    private(set) var errorMessage: String?
    private(set) var lastTokenCount: Int?

    // MARK: Initialization

    init(ai: any AIProviding, analytics: any AnalyticsProviding) {
        self.ai = ai
        self.analytics = analytics

        // Add welcome message
        messages.append(AIMessage(
            role: .model,
            content: "Hello! I'm powered by Gemini through Firebase AI. " +
                "Try asking me about restaurants, recipes, or anything else!"
        ))
    }

    // MARK: Actions

    /// Sends the current input text using the selected mode.
    func send() async {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        // Add user message
        let userMessage = AIMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""

        isLoading = true
        errorMessage = nil

        do {
            switch selectedMode {
            case .generate:
                try await handleGenerate(text)
            case .stream:
                try await handleStream(text)
            case .chat:
                try await handleChat(text)
            }

            analytics.logEvent("ai_message_sent", parameters: [
                "mode": selectedMode.rawValue.lowercased()
            ])
        } catch {
            errorMessage = error.localizedDescription
            print("AI error: \(error)")
        }

        isLoading = false
    }

    /// Clears the chat history.
    func clearChat() {
        messages.removeAll()
        chatHistory.removeAll()
        lastTokenCount = nil

        messages.append(AIMessage(
            role: .model,
            content: "Chat cleared. Ask me anything!"
        ))
    }

    /// Clears the error message.
    func clearError() {
        errorMessage = nil
    }

    // MARK: Private Helpers

    private func handleGenerate(_ text: String) async throws {
        let response = try await ai.generateContent(
            prompt: text,
            configuration: configuration
        )

        messages.append(AIMessage(role: .model, content: response.content))
        lastTokenCount = response.totalTokenCount
    }

    private func handleStream(_ text: String) async throws {
        isStreaming = true

        // Add placeholder for streaming response
        var streamedContent = ""
        let modelIndex = messages.count
        messages.append(AIMessage(role: .model, content: ""))

        let stream = ai.streamContent(prompt: text, configuration: configuration)
        for try await chunk in stream {
            streamedContent += chunk
            messages[modelIndex] = AIMessage(role: .model, content: streamedContent)
        }

        isStreaming = false
    }

    private func handleChat(_ text: String) async throws {
        // Build history from previous messages (excluding welcome)
        chatHistory.append(AIMessage(role: .user, content: text))

        let response = try await ai.sendMessage(
            text,
            history: chatHistory.dropLast().map { $0 },
            systemInstruction: nil,
            configuration: configuration
        )

        let modelMessage = AIMessage(role: .model, content: response.content)
        messages.append(modelMessage)
        chatHistory.append(modelMessage)
        lastTokenCount = response.totalTokenCount
    }
}

// MARK: - Previews

#Preview("AI Chat - Empty") {
    AIChatView()
        .previewEnvironment()
}

#Preview("AI Chat - Dark") {
    AIChatView()
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
