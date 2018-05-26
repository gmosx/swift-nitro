// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Nitro",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Nitro",
            dependencies: [
                "NIO",
                "NIOHTTP1",
            ]
        ),
        .target(
            name: "nitro-example",
            dependencies: [
                .target(name: "Nitro")
            ]
        ),
    ]
)
