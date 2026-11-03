// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MockCRIOrchestrator",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MockCRIOrchestrator",
            targets: ["MockCRIOrchestrator"]
        ),
    ],
    targets: [
        .target(
            name: "MockCRIOrchestrator"
        ),
        .testTarget(
            name: "MockCRIOrchestratorTests",
            dependencies: ["MockCRIOrchestrator"]
        )
    ]
)
