// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let resources: [Resource] = [
    .copy("Resources/YOLO8s.mlpackage"),
    .copy("Resources/col.mlmodel"),
    .copy("Resources/test_sample.jpeg"),
    .copy("Sounds/alarm.wav"),
    .copy("Sounds/cputer1.wav"),
    .copy("Sounds/cputer2.wav"),
    .copy("Sounds/r2d21.wav"),
    .copy("Sounds/r2d22.wav"),
    .copy("Sounds/ping.wav"),
    .copy("Sounds/scream.wav"),
    .copy("Sounds/pcup.wav"),
]

let package = Package(
    name: "Features",
    platforms: [.macOS("14.0.0"), .iOS("17.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Features",
            targets: ["Features"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.15.0"),
        .package(path: "../Connection")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Features",
            dependencies: [
                .product(name: "Connection", package: "Connection"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: resources),
        .testTarget(
            name: "FeatureTests",
            dependencies: ["Features"],
            resources: resources),
    ]
)
