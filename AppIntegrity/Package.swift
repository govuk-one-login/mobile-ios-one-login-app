// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppIntegrity",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AppIntegrity", targets: ["AppIntegrity"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            exact: "12.3.0"
        ),
        .package(
            url: "https://github.com/govuk-one-login/mobile-ios-networking",
            from: "3.3.0"
        )
    ],
    targets: [
        .target(name: "AppIntegrity", dependencies: [
            .product(name: "Networking", package: "mobile-ios-networking"),
            .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk")
        ]),
        .testTarget(name: "AppIntegrityTests", dependencies: [
            "AppIntegrity",
            .product(name: "MockNetworking", package: "mobile-ios-networking")
        ])
    ]
)
