import SwiftUI

/// SwiftUI Environment key for analytics provider.
public struct AnalyticsProviderKey: EnvironmentKey {
    public static let defaultValue: any AnalyticsProviding = FirebaseAnalyticsProvider.live
}

extension EnvironmentValues {
    /// The analytics provider in the environment.
    public var analyticsProvider: any AnalyticsProviding {
        get { self[AnalyticsProviderKey.self] }
        set { self[AnalyticsProviderKey.self] = newValue }
    }
}
