// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Differ",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Differ",
            targets: ["Differ"]
        )
    ],
    dependencies: [
        // Local module packages
        .package(path: "Modules/DifferCore"),
        .package(path: "Modules/DifferKit"),
        .package(path: "Modules/DifferServices"),
        .package(path: "Modules/DifferUI"),
    ],
    targets: [
        .executableTarget(
            name: "Differ",
            dependencies: [
                .product(name: "DifferCore", package: "DifferCore"),
                .product(name: "DifferKit", package: "DifferKit"),
                .product(name: "DifferServices", package: "DifferServices"),
                .product(name: "DifferUI", package: "DifferUI"),
            ],
            path: "App"
        )
    ]
)
