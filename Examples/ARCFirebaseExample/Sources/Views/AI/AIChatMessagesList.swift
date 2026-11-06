//
//  AIChatMessagesList.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import ARCFirebaseAI
import SwiftUI

// MARK: - AIChatMessagesList

/// Scrolling list of chat messages with a streaming indicator.
struct AIChatMessagesList: View {
    let viewModel: AIChatViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(viewModel.messages.enumerated()),
                            id: \.offset) { index, message in
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
    }
}

#Preview {
    AIChatMessagesList(viewModel: AIChatViewModel(ai: PreviewEnvironment.aiProvider,
                                                  analytics: PreviewEnvironment.analyticsProvider))
}
