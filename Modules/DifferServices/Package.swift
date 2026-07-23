// swift-tools-version: 5.9
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
        .package(path: "../DifferKit"),
        // External dependencies
        .package(url: "https://github.com/davidahouse/XCResultKit.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DifferServices",
            dependencies: [
                .product(name: "DifferCore", package: "DifferCore"),
                .product(name: "DifferKit", package: "DifferKit"),
                "XCResultKit",
                .product(name: "Logging", package: "swift-log")
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
