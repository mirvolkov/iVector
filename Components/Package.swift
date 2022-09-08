// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let resources: [Resource] = [
//    .process("MobileNetV2.mlmodel"),
    .copy("Fonts/*"),
    .process("Fonts/RobotoMono-Bold.ttf"),
]


let package = Package(
    name: "Components",
    platforms: [.macOS("12.0.0"), .iOS("15.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Components",
            targets: ["Components"]),
    ],
    dependencies: [
        .package(path: "../Features"),
        .package(path: "../Connection")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Components",
            dependencies: [.product(name: "Connection", package: "Connection"),
                           .product(name: "Features", package: "Features")],
            resources: resources),
        .testTarget(
            name: "ComponentsTests",
            dependencies: ["Components"],
            resources: resources),
    ]
)
