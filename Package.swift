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
        .library(
            name: "LocationHistoryConsumerAppSupport",
            targets: ["LocationHistoryConsumerAppSupport"]
        ),
        .library(
            name: "LocationHistoryConsumerDemoSupport",
            targets: ["LocationHistoryConsumerDemoSupport"]
        ),
        .executable(
            name: "LocationHistoryConsumerDemo",
            targets: ["LocationHistoryConsumerDemo"]
        ),
        .executable(
            name: "LocationHistoryConsumerApp",
            targets: ["LocationHistoryConsumerApp"]
        ),
    ],
    targets: [
        .target(
            name: "LocationHistoryConsumer"
        ),
        .target(
            name: "LocationHistoryConsumerAppSupport",
            dependencies: ["LocationHistoryConsumer"]
        ),
        .target(
            name: "LocationHistoryConsumerDemoSupport",
            dependencies: ["LocationHistoryConsumerAppSupport"],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "LocationHistoryConsumerDemo",
            dependencies: [
                "LocationHistoryConsumerAppSupport",
                "LocationHistoryConsumerDemoSupport",
            ]
        ),
        .executableTarget(
            name: "LocationHistoryConsumerApp",
            dependencies: [
                "LocationHistoryConsumerAppSupport",
                "LocationHistoryConsumerDemoSupport",
            ]
        ),
        .testTarget(
            name: "LocationHistoryConsumerTests",
            dependencies: [
                "LocationHistoryConsumer",
                "LocationHistoryConsumerAppSupport",
                "LocationHistoryConsumerDemoSupport",
            ]
        ),
    ]
)
