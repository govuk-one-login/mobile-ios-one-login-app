// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Orchestrator",
    platforms: [.iOS("16.7")],
    products: [
        .library(
            name: "Orchestrator",
            targets: ["Orchestrator"]
        ),
        .library(
            name: "MockOrchestrator",
            targets: ["MockOrchestrator"]
        ),
        .library(
            name: "OrchestratorInterfaces",
            targets: ["OrchestratorInterfaces"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/govuk-one-login/mobile-id-check-ios-sdk.git",
            exact: "8.88.0"
        )
    ],
    targets: [
        .target(
            name: "Orchestrator",
            dependencies: [
                "OrchestratorInterfaces",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]),
        .target(
            name: "MockOrchestrator",
            dependencies: [
                "OrchestratorInterfaces",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]),
        .target(
            name: "OrchestratorInterfaces",
            dependencies: [
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]),
        .testTarget(
            name: "MockOrchestratorTests",
            dependencies: [
                "MockOrchestrator",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        )
    ]
)
