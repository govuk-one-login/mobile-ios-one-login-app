// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OneLoginCRIOrchestrator",
    platforms: [.iOS("16.7")],
    products: [
        // Protocol
        .library(
            name: "CRIOrchestratorProtocol",
            targets: ["CRIOrchestratorProtocol"]
        ),
        // Wrapper
        .library(
            name: "OneLoginCRIOrchestrator",
            targets: ["OneLoginCRIOrchestrator"]
        ),
        // Mock
        .library(
            name: "MockCRIOrchestrator",
            targets: ["MockCRIOrchestrator"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/govuk-one-login/mobile-id-check-ios-sdk.git",
            exact: "8.93.0"
        )
    ],
    targets: [
        // Protocol
        .target(
            name: "CRIOrchestratorProtocol",
            dependencies: [
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        ),
        // Wrapper
        .target(
            name: "OneLoginCRIOrchestrator",
            dependencies: [
                "CRIOrchestratorProtocol",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        ),
        // Mock
        .target(
            name: "MockCRIOrchestrator",
            dependencies: [
                "CRIOrchestratorProtocol",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        ),
        .testTarget(
            name: "MockCRIOrchestratorTests",
            dependencies: [
                "MockCRIOrchestrator",
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        )
    ]
)
