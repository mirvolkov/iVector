// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: [Target.Dependency] = [
    .product(name: "GRPC", package: "grpc-swift"),
    .product(name: "NIO", package: "swift-nio"),
    .product(name: "SwiftProtobuf", package: "swift-protobuf"),
    .product(name: "SwiftProtobufPluginLibrary", package: "swift-protobuf"),
    .product(name: "SocketIO", package: "socket.io-client-swift"),
    .product(name: "BLE", package: "BLE"),
    .product(name: "SwiftBus", package: "SwiftBus")
]

let resources: [Resource] = [
    .copy("Resources/mock_vision.jpeg"),
    .copy("Resources/mock_rec.mp4"),
    .copy("Resources/mock_robot_state.json"),
    .copy("Cert/vector.cert")
]

let package = Package(
    name: "Connection",
    platforms: [.macOS("14.0.0"), .iOS("17.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Connection",
            targets: ["Connection"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/apple/swift-protobuf.git", exact: "1.19.0"),
         .package(url: "https://github.com/apple/swift-nio.git", exact: "2.40.0"),
         .package(url: "https://github.com/grpc/grpc-swift", exact: "1.0.0"),
         .package(url: "https://github.com/socketio/socket.io-client-swift", exact: "15.2.0"),
         .package(url: "https://github.com/mtynior/SwiftBus.git", .upToNextMajor(from: "1.0.0")),
         .package(path: "../BLE"),
    ],
    targets: [
        .target(
            name: "Connection",
            dependencies: dependencies,
            resources: resources),
        .testTarget(
            name: "ConnectionTests",
            dependencies: ["Connection"],
            resources: resources),
    ]
)
