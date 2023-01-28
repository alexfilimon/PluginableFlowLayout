// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PluginableFlowLayout",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "PluginableFlowLayout",
            targets: ["PluginableFlowLayout"]),
    ],
    targets: [
        .target(
            name: "PluginableFlowLayout",
            dependencies: []),
    ]
)
