// swift-tools-version:5.9.2

import PackageDescription

let package = Package(
    name: "Utils9AIAdapter",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v10_15)],
    products: [
        .library(name: "Utils9AIAdapter", targets: ["Utils9AIAdapter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tomattoz/utils", branch: "master"),
        .package(url: "https://github.com/tomattoz/utils4Crypto", branch: "master"),
    ],
    targets: [
        .target(name: "Utils9AIAdapter",
                dependencies: [
                    .product(name: "Utils9", package: "utils"),
                    .product(name: "CryptoUtils9", package: "utils4Crypto")
                ],
                path: "Sources")
    ]
)
