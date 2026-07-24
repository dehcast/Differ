// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DifferCore",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DifferCore",
            targets: ["DifferCore"]
        )
    ],
    targets: [
        .target(
            name: "DifferCore",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "DifferCoreTests",
            dependencies: ["DifferCore"],
            path: "Tests"
        )
    ]
)
