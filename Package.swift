// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Nitro",
    products: [
        .library(name: "Nitro", targets: ["Nitro"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0"),
        .package(url: "https://github.com/reizu/swift-logging.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Nitro",
            dependencies: [
                "NIO",
                "NIOHTTP1",
                "Logging",
            ]
        ),
        .target(
            name: "nitro-example",
            dependencies: [
                .target(name: "Nitro"),
            ]
        ),
    ]
)
