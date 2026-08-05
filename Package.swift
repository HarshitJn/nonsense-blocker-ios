// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "NonsenseBlocker",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "NonsenseBlockerCore",
            targets: ["NonsenseBlockerCore"]
        ),
        .executable(
            name: "NonsenseBlockerTestRunner",
            targets: ["NonsenseBlockerTestRunner"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NonsenseBlockerCore",
            dependencies: []
        ),
        .executableTarget(
            name: "NonsenseBlockerTestRunner",
            dependencies: ["NonsenseBlockerCore"]
        )
    ]
)
