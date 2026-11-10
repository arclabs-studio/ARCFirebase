//
//  AIChatInputBar.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-18.
//

import SwiftUI

// MARK: - AIChatInputBar

/// Generation mode picker plus the prompt field and send button.
struct AIChatInputBar: View {
    @Bindable var viewModel: AIChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $viewModel.selectedMode) {
                ForEach(AIChatViewModel.ChatMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            HStack(spacing: 12) {
                TextField("Ask something...", text: $viewModel.inputText, axis: .vertical)
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
    }
}

#Preview {
    AIChatInputBar(viewModel: AIChatViewModel(ai: PreviewEnvironment.aiProvider,
                                              analytics: PreviewEnvironment.analyticsProvider))
}
