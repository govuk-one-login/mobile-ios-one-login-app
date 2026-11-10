// swift-tools-version:  5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDKInterface",
    platforms: [.iOS("16.7")],
    products: [
        .library(
            name: "SDKInterface",
            targets: ["SDKInterface"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/govuk-one-login/mobile-id-check-ios-sdk.git",
            .upToNextMajor(from: .init(8, 88, 0))
        )
    ],
    targets: [
        .target(
            name: "SDKInterface",
            dependencies: [
                .product(name: "CRIOrchestrator", package: "mobile-id-check-ios-sdk")
            ]
        )
    ]
)
