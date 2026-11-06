//
//  AIChatOptionsMenu.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import SwiftUI

// MARK: - AIChatOptionsMenu

/// Toolbar menu to clear the chat and pick a generation configuration.
struct AIChatOptionsMenu: View {
    @Bindable var viewModel: AIChatViewModel

    var body: some View {
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

#Preview {
    AIChatOptionsMenu(viewModel: AIChatViewModel(ai: PreviewEnvironment.aiProvider,
                                                 analytics: PreviewEnvironment.analyticsProvider))
}
