//
//  CrashlyticsProviderKey.swift
//  ARCFirebase
//
//  Created by ARC Labs Studio on 13/01/2026.
//

import SwiftUI

/// SwiftUI Environment key for crashlytics provider.
///
/// This allows passing the crashlytics provider through the SwiftUI environment:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     let crashlytics = FirebaseCrashlyticsProvider.live
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(\.crashlyticsProvider, crashlytics)
///         }
///     }
/// }
///
/// struct MyView: View {
///     @Environment(\.crashlyticsProvider) var crashlytics
///
///     func handleError(_ error: Error) {
///         crashlytics.record(error: error)
///     }
/// }
/// ```
public struct CrashlyticsProviderKey: EnvironmentKey {
    public static let defaultValue: any CrashlyticsProviding = FirebaseCrashlyticsProvider.live
}

extension EnvironmentValues {
    /// The crashlytics provider in the environment.
    public var crashlyticsProvider: any CrashlyticsProviding {
        get { self[CrashlyticsProviderKey.self] }
        set { self[CrashlyticsProviderKey.self] = newValue }
    }
}
