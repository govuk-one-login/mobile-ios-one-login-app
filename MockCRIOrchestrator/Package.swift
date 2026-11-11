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
        )
    ],
    dependencies: [
        .package(path: "../SDKInterface"),
        .package(
            url: "https://github.com/govuk-one-login/mobile-id-check-ios-sdk.git",
            .upToNextMajor(from: .init(8, 88, 0))
        )
    ],
    targets: [
        .target(
            name: "MockCRIOrchestrator",
            dependencies: [
                .product(name: "SDKInterface", package: "SDKInterface"),
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
