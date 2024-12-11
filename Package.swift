// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KaspaSwift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "kaspaswift",
            targets: ["kaspaswift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(url: "https://github.com/mathwallet/Secp256k1Swift", from: "2.0.0"),
        .package(url: "https://github.com/mathwallet/BIP39swift", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
        .package(url: "https://github.com/lishuailibertine/Bech32", from: "1.0.5"),
        .package(url: "https://github.com/lishuailibertine/Blake2.swift", from: "0.1.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "kaspaswift",
            dependencies: [
                "CryptoSwift",
                "Secp256k1Swift",
                .product(name: "BIP32Swift", package: "Secp256k1Swift"),
                "BIP39swift",
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "GRPC", package: "grpc-swift"),
                "Bech32",
                .product(name: "Blake2", package: "blake2.swift")
            ],
            path: "Sources/kaspaswift"
        ),
        .testTarget(
            name: "kaspaswiftTests",
            dependencies: ["kaspaswift"]
        ),
    ]
)
