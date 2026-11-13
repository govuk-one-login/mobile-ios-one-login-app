// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CRIOrchestration",
    platforms: [.iOS("16.7")],
    products: [
        .library(
            name: "CRIOrchestratorInterface",
            targets: ["CRIOrchestratorInterface"]
        ),
        .library(
            name: "MockCRIOrchestrator",
            targets: ["MockCRIOrchestrator"]
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
            name: "CRIOrchestratorInterface",
            dependencies: [
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        ),
        .target(
            name: "MockCRIOrchestrator",
            dependencies: [
                "CRIOrchestratorInterface",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        ),
        .testTarget(
            name: "MockCRIOrchestratorTests",
            dependencies: [
                "CRIOrchestratorInterface",
                "MockCRIOrchestrator"
            ]
        )
    ]
)
