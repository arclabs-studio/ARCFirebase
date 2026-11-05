//
//  FeatureFlagsBooleanSection.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import SwiftUI

// MARK: - FeatureFlagsBooleanSection

/// List section showing the on/off feature flags.
struct FeatureFlagsBooleanSection: View {
    let viewModel: FeatureFlagsDemoViewModel

    var body: some View {
        Section("Boolean Flags") {
            FlagRow(icon: "sparkles",
                    title: "New Onboarding v2",
                    value: viewModel.isNewOnboardingEnabled ? "Enabled" : "Disabled",
                    isEnabled: viewModel.isNewOnboardingEnabled)

            FlagRow(icon: "moon.fill",
                    title: "Dark Mode",
                    value: viewModel.isDarkModeEnabled ? "Enabled" : "Disabled",
                    isEnabled: viewModel.isDarkModeEnabled)

            FlagRow(icon: "star.fill",
                    title: "Premium Features",
                    value: viewModel.isPremiumEnabled ? "Enabled" : "Disabled",
                    isEnabled: viewModel.isPremiumEnabled)

            FlagRow(icon: "wrench.fill",
                    title: "Maintenance Mode",
                    value: viewModel.isMaintenanceMode ? "Active" : "Inactive",
                    isEnabled: viewModel.isMaintenanceMode)
        }
    }
}

#Preview {
    let viewModel = FeatureFlagsDemoViewModel(featureFlags: PreviewEnvironment.featureFlagProvider,
                                              analytics: PreviewEnvironment.analyticsProvider)

    return List {
        FeatureFlagsBooleanSection(viewModel: viewModel)
    }
}
