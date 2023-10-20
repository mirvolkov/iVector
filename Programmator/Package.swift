// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Programmator",
    platforms: [.macOS("14.0.0"), .iOS("17.0")],
    products: [
        .library(
            name: "Programmator",
            targets: ["Programmator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick", branch: "main"),
        .package(url: "https://github.com/Quick/Nimble", branch: "main"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.3"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(path: "../Features")
    ],
    targets: [
        .target(
            name: "Programmator",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Features", package: "Features")
            ]),
        .testTarget(
            name: "ProgrammatorTests",
            dependencies: [
                "Programmator",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble")
            ]),
    ])
