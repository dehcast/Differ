// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DifferServices",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DifferServices",
            targets: ["DifferServices"]
        )
    ],
    dependencies: [
        .package(path: "../DifferCore"),
        .package(path: "../DifferKit")
    ],
    targets: [
        .target(
            name: "DifferServices",
            dependencies: [
                .product(name: "DifferCore", package: "DifferCore"),
                .product(name: "DifferKit", package: "DifferKit")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "DifferServicesTests",
            dependencies: ["DifferServices"],
            path: "Tests"
        )
    ]
)
