// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OneLoginWallet",
    platforms: [.iOS("16.7")],
    products: [
        // Protocol
        .library(
            name: "WalletProtocol",
            targets: ["WalletProtocol"]
        ),
        // Wrapper
        .library(
            name: "OneLoginWallet",
            targets: ["OneLoginWallet"]
        ),
        // Mock
        .library(
            name: "MockWallet",
            targets: ["MockWallet"]
        )
    ],
    dependencies: [
        .package(path:"../mobile-wallet-ios")
    ],
    targets: [
        // Protocol
        .target(
            name: "WalletProtocol",
            dependencies: [
                .product(name: "Wallet", package: "mobile-wallet-ios")
            ]
        ),
        // Wrapper
        .target(
            name: "OneLoginWallet",
            dependencies: [
                "WalletProtocol",
                .product(name: "Wallet", package: "mobile-wallet-ios")
            ]
        ),
        // Mock
        .target(
            name: "MockWallet",
            dependencies: [
                "WalletProtocol",
                .product(name: "Wallet", package: "mobile-wallet-ios")
            ]
        ),
        .testTarget(
            name: "MockWalletTests",
            dependencies: [
                "WalletProtocol",
                "MockWallet",
                .product(name: "Wallet", package: "mobile-wallet-ios")
            ]
        )
    ]
)
