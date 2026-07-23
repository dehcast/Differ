// swift-tools-version: 5.9
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
