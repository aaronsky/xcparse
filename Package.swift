// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcparse",
    products: [
        .executable(name: "xcparse", targets: ["xcparse"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "XCParseCore",
            dependencies: ["Utility", "Yams"]),
        .target(
            name: "xcparse",
            dependencies: ["XCParseCore"])
    ]
)
