// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "GPEngine",
    products: [
        .library(name: "GPEngine", targets: ["GPEngine"]),
        .library(name: "GPSerialization", targets: ["Serialization"])
    ],
    targets: [
        .target(name: "GPEngine"),
        .target(name: "Serialization",
                dependencies: ["GPEngine"]),
        .testTarget(name: "GPEngineTests",
                    dependencies: ["GPEngine"]),
        .testTarget(name: "SerializationTests",
                    dependencies: ["GPEngine", "Serialization"])
    ],
    swiftLanguageVersions: [.v5]
)
