// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let resources: [Resource] = [
    .process("Fonts/RobotoMono-Bold.ttf"),
    .copy("Animation/loading.json"),
    .copy("Animation/mic.json"),
    .copy("Animation/cam.json"),
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
        .package(path: "../Connection"),
        .package(url: "https://github.com/airbnb/lottie-ios", exact: "3.4.3")
    ],
    targets: [
        .target(
            name: "Components",
            dependencies: [.product(name: "Connection", package: "Connection"),
                           .product(name: "Features", package: "Features"),
                           .product(name: "Lottie", package: "lottie-ios")],
            resources: resources),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"],
            resources: resources
        ),
    ]
)
