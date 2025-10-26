// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EventChainsSwift",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "EventChainsSwift",
            targets: ["EventChainsSwift"]),
        .executable(
            name: "EventChainsDemo",
            targets: ["EventChainsDemo"]),
        .executable(
            name: "EventChainsBenchmark",
            targets: ["EventChainsBenchmark"])
    ],
    targets: [
        .target(
            name: "EventChainsSwift",
            dependencies: []),
        .executableTarget(
            name: "EventChainsDemo",
            dependencies: ["EventChainsSwift"]),
        .executableTarget(
            name: "EventChainsBenchmark",
            dependencies: ["EventChainsSwift"]),
        .testTarget(
            name: "EventChainsSwiftTests",
            dependencies: ["EventChainsSwift"])
    ]
)
