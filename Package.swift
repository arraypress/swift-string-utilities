// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StringUtilities",
    platforms: [
        .macOS(.v14), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1),
    ],
    products: [
        .library(name: "StringUtilities", targets: ["StringUtilities"]),
    ],
    targets: [
        .target(name: "StringUtilities"),
        .testTarget(name: "StringUtilitiesTests", dependencies: ["StringUtilities"]),
    ]
)
