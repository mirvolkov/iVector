// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let resources: [Resource] = [
    .process("Fonts/RobotoMono-Bold.ttf"),
]


let package = Package(
    name: "Components",
    defaultLocalization: "en",
    platforms: [.macOS("12.0.0"), .iOS("15.0")],
    products: [
        .library(
            name: "Components",
            targets: ["Components"]),
    ],
    dependencies: [
        .package(path: "../Features"),
        .package(path: "../Connection")
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [.product(name: "Connection", package: "Connection"),
                           .product(name: "Features", package: "Features")],
            resources: resources),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"],
            resources: resources
        ),
    ]
)
