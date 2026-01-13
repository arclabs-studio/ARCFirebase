import SwiftUI

/// SwiftUI Environment key for storage provider.
public struct StorageProviderKey: EnvironmentKey {
    public static let defaultValue: any StorageProviding = FirebaseStorageProvider.live
}

extension EnvironmentValues {
    /// The storage provider in the environment.
    public var storageProvider: any StorageProviding {
        get { self[StorageProviderKey.self] }
        set { self[StorageProviderKey.self] = newValue }
    }
}
