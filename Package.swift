// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "GPEngine",
    dependencies: [
    ],
    targets: [
        .target(name: "GPEngine"),
        // .target(name: "Serialization", dependencies: ["GPEngine"])
        .testTarget(name: "GPEngineTests",
                    dependencies: ["GPEngine"])
    ],
    swiftLanguageVersions: [.v4_2]
)
