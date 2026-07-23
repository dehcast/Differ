// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DifferUI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DifferUI",
            targets: ["DifferUI"]
        )
    ],
    dependencies: [
        .package(path: "../DifferCore"),
        .package(path: "../DifferKit"),
        .package(path: "../DifferServices"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")
    ],
    targets: [
        .target(
            name: "DifferUI",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DifferCore", package: "DifferCore"),
                .product(name: "DifferKit", package: "DifferKit"),
                .product(name: "DifferServices", package: "DifferServices")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DifferUITests",
            dependencies: [
                "DifferUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests"
        )
    ]
)
