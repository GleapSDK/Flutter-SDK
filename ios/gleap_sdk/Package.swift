// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gleap_sdk",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "gleap-sdk", targets: ["gleap_sdk"])
    ],
    dependencies: [
        .package(url: "https://github.com/GleapSDK/Gleap-iOS-SDK.git", from: "15.3.0")
    ],
    targets: [
        .target(
            name: "gleap_sdk",
            dependencies: [
                .product(name: "Gleap", package: "Gleap-iOS-SDK")
            ],
            cSettings: [
                .headerSearchPath("include")
            ]
        )
    ]
)
