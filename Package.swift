// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCFirebase",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        // Core - Required by all other modules
        .library(
            name: "ARCFirebaseCore",
            targets: ["ARCFirebaseCore"]
        ),

        // Individual modules
        .library(
            name: "ARCFirebaseAuth",
            targets: ["ARCFirebaseAuth"]
        ),
        .library(
            name: "ARCFirebaseAnalytics",
            targets: ["ARCFirebaseAnalytics"]
        ),
        .library(
            name: "ARCFirebaseCrashlytics",
            targets: ["ARCFirebaseCrashlytics"]
        ),
        .library(
            name: "ARCFirebasePersistence",
            targets: ["ARCFirebasePersistence"]
        ),
        .library(
            name: "ARCFirebaseStorage",
            targets: ["ARCFirebaseStorage"]
        ),

        // Convenience: All modules in one
        .library(
            name: "ARCFirebase",
            targets: [
                "ARCFirebaseCore",
                "ARCFirebaseAuth",
                "ARCFirebaseAnalytics",
                "ARCFirebaseCrashlytics",
                "ARCFirebasePersistence",
                "ARCFirebaseStorage"
            ]
        )
    ],
    dependencies: [
        // Firebase iOS SDK
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "10.0.0"
        ),

        // ARC Labs Logger
        .package(path: "../ARCLogger")
    ],
    targets: [
        // MARK: - Core

        .target(
            name: "ARCFirebaseCore",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCFirebaseCore",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // MARK: - Auth

        .target(
            name: "ARCFirebaseAuth",
            dependencies: [
                "ARCFirebaseCore",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCFirebaseAuth",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // MARK: - Analytics

        .target(
            name: "ARCFirebaseAnalytics",
            dependencies: [
                "ARCFirebaseCore",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCFirebaseAnalytics",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // MARK: - Crashlytics

        .target(
            name: "ARCFirebaseCrashlytics",
            dependencies: [
                "ARCFirebaseCore",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCFirebaseCrashlytics",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // MARK: - Persistence

        .target(
            name: "ARCFirebasePersistence",
            dependencies: [
                "ARCFirebaseCore",
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCFirebasePersistence",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // MARK: - Storage

        .target(
            name: "ARCFirebaseStorage",
            dependencies: [
                "ARCFirebaseCore",
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "ARCLogger", package: "ARCLogger")
            ],
            path: "Sources/ARCFirebaseStorage",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),

        // MARK: - Tests

        .testTarget(
            name: "ARCFirebaseCoreTests",
            dependencies: ["ARCFirebaseCore"]
        ),
        .testTarget(
            name: "ARCFirebaseAuthTests",
            dependencies: ["ARCFirebaseAuth"]
        ),
        .testTarget(
            name: "ARCFirebaseAnalyticsTests",
            dependencies: ["ARCFirebaseAnalytics"]
        ),
        .testTarget(
            name: "ARCFirebaseCrashlyticsTests",
            dependencies: ["ARCFirebaseCrashlytics"]
        ),
        .testTarget(
            name: "ARCFirebasePersistenceTests",
            dependencies: ["ARCFirebasePersistence"]
        ),
        .testTarget(
            name: "ARCFirebaseStorageTests",
            dependencies: ["ARCFirebaseStorage"]
        )
    ]
)
