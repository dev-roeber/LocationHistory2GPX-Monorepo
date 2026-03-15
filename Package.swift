// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LocationHistoryConsumer",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "LocationHistoryConsumer",
            targets: ["LocationHistoryConsumer"]
        ),
    ],
    targets: [
        .target(
            name: "LocationHistoryConsumer"
        ),
        .testTarget(
            name: "LocationHistoryConsumerTests",
            dependencies: ["LocationHistoryConsumer"]
        ),
    ]
)
