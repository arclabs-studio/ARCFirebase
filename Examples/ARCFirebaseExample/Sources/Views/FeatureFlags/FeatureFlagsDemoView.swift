//
//  FeatureFlagsDemoView.swift
//  ARCFirebaseExample
//
//  Created by ARC Labs Studio on 2026-02-24.
//

import ARCFirebaseAnalytics
import ARCFirebaseFeatureFlags
import SwiftUI

// MARK: - FeatureFlagsDemoView

/// Demonstrates Firebase Remote Config feature flags: fetch, read, and real-time updates.
///
/// This view showcases the `FeatureFlagProviding` protocol with:
///
/// 1. **Fetch & Activate**: Pull latest config from Firebase Remote Config
/// 2. **Typed Accessors**: Read Bool, String, Int, Double values
/// 3. **Default Values**: Fallback values when no remote value is set
/// 4. **Real-Time Updates**: Listen for config changes via `configUpdates()`
///
/// ## Key Concepts
///
/// - Feature flags decouple deployment from feature release
/// - Use `isEnabled(_:)` for simple on/off flags
/// - Use typed accessors (`int(forKey:)`, `string(forKey:)`) for configuration values
/// - Real-time updates let you change behavior without app restart
struct FeatureFlagsDemoView: View {
    // MARK: Private Properties

    /// Access to feature flag provider from environment.
    @Environment(\.featureFlagProvider) private var featureFlags

    /// Access to analytics for event tracking.
    @Environment(\.analyticsProvider) private var analytics

    /// The view model managing feature flag operations.
    @State private var viewModel: FeatureFlagsDemoViewModel?

    // MARK: View

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    flagsContent(viewModel)
                } else {
                    ProgressView("Initializing...")
                }
            }
            .navigationTitle("Feature Flags")
            .task {
                if viewModel == nil {
                    viewModel = FeatureFlagsDemoViewModel(featureFlags: featureFlags,
                                                          analytics: analytics)
                }
            }
        }
    }
}

// MARK: - Private Views

extension FeatureFlagsDemoView {
    private func flagsContent(_ viewModel: FeatureFlagsDemoViewModel) -> some View {
        List {
            // ==============================================================
            // Fetch Section
            // ==============================================================
            Section {
                fetchSection(viewModel)
            } header: {
                Text("Remote Config")
            } footer: {
                Text("Fetches the latest feature flag values from Firebase Remote Config")
            }

            // ==============================================================
            // Boolean Flags Section
            // ==============================================================
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

            // ==============================================================
            // Configuration Values Section
            // ==============================================================
            Section("Configuration Values") {
                FlagRow(icon: "arrow.up.circle",
                        title: "Max Upload Size",
                        value: "\(viewModel.maxUploadSizeMB) MB",
                        isEnabled: true)

                FlagRow(icon: "clock",
                        title: "API Timeout",
                        value: String(format: "%.0fs", viewModel.apiTimeout),
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

            // ==============================================================
            // How It Works Section
            // ==============================================================
            Section("How It Works") {
                howItWorksContent
            }
        }
        .refreshable {
            await viewModel.fetchFlags()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    private func fetchSection(_ viewModel: FeatureFlagsDemoViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last fetched")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let lastFetch = viewModel.lastFetchDate {
                        Text(lastFetch, style: .relative)
                            .font(.headline)
                            + Text(" ago")
                            .font(.headline)
                    } else {
                        Text("Never")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if viewModel.updateCount > 0 {
                    Label("\(viewModel.updateCount)", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Button {
                Task {
                    await viewModel.fetchFlags()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise.circle.fill")
                    }
                    Text("Fetch & Activate")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding(.vertical, 8)
    }

    private var howItWorksContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(icon: "arrow.down.circle",
                    title: "Fetch",
                    description: "flags.fetchAndActivate()")

            InfoRow(icon: "switch.2",
                    title: "Bool Flag",
                    description: "flags.isEnabled(\"feature_key\")")

            InfoRow(icon: "number",
                    title: "Typed Value",
                    description: "flags.int(forKey: \"max_count\")")

            InfoRow(icon: "antenna.radiowaves.left.and.right",
                    title: "Real-Time",
                    description: "for await _ in flags.configUpdates()")
        }
        .font(.caption)
    }
}

// MARK: - FlagRow

/// A row displaying a feature flag name and its current value.
struct FlagRow: View {
    let icon: String
    let title: String
    let value: String
    let isEnabled: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(isEnabled ? .blue : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(isEnabled ? .green : .red.opacity(0.5))
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - FeatureFlagsDemoViewModel

/// ViewModel for the Feature Flags demo screen.
///
/// This ViewModel demonstrates:
/// - Protocol-based feature flag dependency
/// - Async fetch operations
/// - Typed flag reading (Bool, String, Int, Double)
/// - Real-time config update listening
/// - Analytics event tracking
@MainActor
@Observable
final class FeatureFlagsDemoViewModel {
    // MARK: Private Properties

    private let featureFlags: any FeatureFlagProviding
    private let analytics: any AnalyticsProviding
    @ObservationIgnored private nonisolated(unsafe) var updateListenerTask: Task<Void, Never>?

    // MARK: Public State

    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var lastFetchDate: Date?
    private(set) var updateCount = 0

    // MARK: Flag Values

    var isNewOnboardingEnabled: Bool {
        featureFlags.isEnabled("new_onboarding_v2")
    }

    var isDarkModeEnabled: Bool {
        featureFlags.isEnabled("dark_mode_enabled")
    }

    var isPremiumEnabled: Bool {
        featureFlags.isEnabled("premium_features")
    }

    var isMaintenanceMode: Bool {
        featureFlags.isEnabled("maintenance_mode")
    }

    var maxUploadSizeMB: Int {
        featureFlags.int(forKey: "max_upload_size_mb", defaultValue: 10)
    }

    var apiTimeout: Double {
        featureFlags.double(forKey: "api_timeout_seconds", defaultValue: 30.0)
    }

    var welcomeMessage: String {
        featureFlags.string(forKey: "welcome_message", defaultValue: "Welcome!")
    }

    var minAppVersion: String {
        featureFlags.string(forKey: "min_app_version", defaultValue: "1.0.0")
    }

    // MARK: Initialization

    init(featureFlags: any FeatureFlagProviding, analytics: any AnalyticsProviding) {
        self.featureFlags = featureFlags
        self.analytics = analytics
        startListeningForUpdates()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: Operations

    /// Fetches and activates the latest remote config values.
    func fetchFlags() async {
        isLoading = true
        errorMessage = nil

        do {
            try await featureFlags.fetchAndActivate()
            lastFetchDate = Date()

            analytics.logEvent("feature_flags_fetched", parameters: ["flag_count": 8])

            print("🏳️ Feature flags fetched and activated")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Feature flags fetch failed: \(error)")
        }

        isLoading = false
    }

    /// Clears the error message.
    func clearError() {
        errorMessage = nil
    }

    // MARK: Private Helpers

    private func startListeningForUpdates() {
        updateListenerTask = Task { [weak self] in
            guard let self else { return }
            for await _ in featureFlags.configUpdates() {
                updateCount += 1
                analytics.logEvent("feature_flags_updated")
                print("🏳️ Feature flags updated remotely (update #\(updateCount))")
            }
        }
    }
}

// MARK: - Previews

#Preview("Feature Flags - Light") {
    FeatureFlagsDemoView()
        .previewEnvironment()
}

#Preview("Feature Flags - Dark") {
    FeatureFlagsDemoView()
        .previewEnvironment()
        .preferredColorScheme(.dark)
}
