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
        .package(path: "../DifferServices")
    ],
    targets: [
        .target(
            name: "DifferUI",
            dependencies: [
                .product(name: "DifferCore", package: "DifferCore"),
                .product(name: "DifferKit", package: "DifferKit"),
                .product(name: "DifferServices", package: "DifferServices")
            ],
            path: "Sources"
        )
    ]
)
