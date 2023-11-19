// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DKAsyncImageView",
    platforms: [.macOS(.v10_10)],
    products: [
        .library(
            name: "DKAsyncImageView",
            targets: ["DKAsyncImageView"]),
    ],
    targets: [
        .target(
            name: "DKAsyncImageView"),
    ]
)
