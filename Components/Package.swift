// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let resources: [Resource] = [
    .process("Fonts/RobotoMono-Bold.ttf"),
    .process("Fonts/RobotoMono-Regular.ttf"),
    .process("Animation/Noise.metal"),
]

let package = Package(
    name: "Components",
    defaultLocalization: "en",
    platforms: [.macOS("14.0.0"), .iOS("17.0")],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]
        ),
    ],
    dependencies: [
        .package(path: "../Features"),
        .package(path: "../Connection"),
        .package(path: "../Programmator"),
        .package(url: "https://github.com/Quick/Quick", branch: "main"),
        .package(url: "https://github.com/Quick/Nimble", branch: "main"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0"),
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [
                .product(name: "Connection", package: "Connection"),
                .product(name: "Features", package: "Features"),
                .product(name: "Programmator", package: "Programmator"),
            ],
            resources: resources,
            plugins: [.plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")]
        ),
        .testTarget(
            name: "ComponentsTests",
            dependencies: [
                "Components",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: resources
        ),
    ]
)
