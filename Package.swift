// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Map",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Map", targets: ["Map"]),
    ],
    targets: [
        .target(name: "Map", path: "Sources"),
        .testTarget(name: "MapTests", dependencies: ["Map"], path: "Tests"),
    ]
)
