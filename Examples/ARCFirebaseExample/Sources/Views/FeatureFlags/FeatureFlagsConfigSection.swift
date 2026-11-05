//
//  FeatureFlagsConfigSection.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import SwiftUI

// MARK: - FeatureFlagsConfigSection

/// List section showing the typed configuration values.
struct FeatureFlagsConfigSection: View {
    let viewModel: FeatureFlagsDemoViewModel

    var body: some View {
        Section("Configuration Values") {
            FlagRow(icon: "arrow.up.circle",
                    title: "Max Upload Size",
                    value: "\(viewModel.maxUploadSizeMB) MB",
                    isEnabled: true)

            FlagRow(icon: "clock",
                    title: "API Timeout",
                    value: "\(viewModel.apiTimeout.formatted(.number.precision(.fractionLength(0))))s",
                    isEnabled: true)

            FlagRow(icon: "text.bubble",
                    title: "Welcome Message",
                    value: viewModel.welcomeMessage,
                    isEnabled: true)

            FlagRow(icon: "app.badge",
                    title: "Min App Version",
                    value: viewModel.minAppVersion,
                    isEnabled: true)
        }
    }
}

#Preview {
    let viewModel = FeatureFlagsDemoViewModel(featureFlags: PreviewEnvironment.featureFlagProvider,
                                              analytics: PreviewEnvironment.analyticsProvider)

    return List {
        FeatureFlagsConfigSection(viewModel: viewModel)
    }
}
