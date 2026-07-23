// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DifferKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DifferKit",
            targets: ["DifferKit"]
        )
    ],
    dependencies: [
        .package(path: "../DifferCore")
    ],
    targets: [
        .target(
            name: "DifferKit",
            dependencies: [
                .product(name: "DifferCore", package: "DifferCore")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DifferKitTests",
            dependencies: ["DifferKit"],
            path: "Tests"
        )
    ]
)
