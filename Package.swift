// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "StoreNinja",
    platforms: [.macOS(.v11), .iOS(.v13)],
    products: [
        .library(
            name: "StoreNinja",
            targets: ["StoreNinja"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/curzel-it/barebones", from: "1.0.0"),
        .package(url: "https://github.com/curzel-it/schwifty", from: "1.0.19")
    ],
    targets: [
        .target(
            name: "StoreNinja",
            dependencies: [
                .product(name: "BareBones", package: "BareBones"),
                .product(name: "Schwifty", package: "Schwifty")
            ]
        ),
        .testTarget(
            name: "StoreNinjaTests",
            dependencies: [
                "StoreNinja",
                .product(name: "BareBones", package: "BareBones"),
                .product(name: "Schwifty", package: "Schwifty")
            ],
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
