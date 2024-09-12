// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobilePlatformServices",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MobilePlatformServices", targets: ["MobilePlatformServices"])
    ],
    dependencies: [
        .package(url: "https://github.com/govuk-one-login/mobile-ios-networking", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(name: "MobilePlatformServices", dependencies: [
            .product(name: "Networking", package: "mobile-ios-networking")
        ]),
        .testTarget(name: "MobilePlatformServicesTests", dependencies: [
            "MobilePlatformServices",
            .product(name: "MockNetworking", package: "mobile-ios-networking")
        ])
    ]
)
