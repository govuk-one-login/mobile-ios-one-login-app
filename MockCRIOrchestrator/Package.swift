// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MockCRIOrchestrator",
    platforms: [.iOS("16.7")],
    products: [
        .library(
            name: "MockCRIOrchestrator",
            targets: ["MockCRIOrchestrator"]
        ),
    ],
    dependencies: [
        .package(path: "SDKInterface")
    ],
    targets: [
        .target(
            name: "MockCRIOrchestrator",
            dependencies: [
                .product(name: "SDKInterface", package: "SDKInterface")
            ]
        ),
        .testTarget(
            name: "MockCRIOrchestratorTests",
            dependencies: ["MockCRIOrchestrator"]
        )
    ]
)
