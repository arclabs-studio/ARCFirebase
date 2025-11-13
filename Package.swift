// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCFirebase",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ARCFirebase",
            targets: ["ARCFirebase"]
        ),
    ],
    targets: [
        .target(
            name: "ARCFirebase",
            path: "Sources"
        ),
        .testTarget(
            name: "ARCFirebaseTests",
            dependencies: ["ARCFirebase"],
            path: "Tests"
        )
    ]
)
