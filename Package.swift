// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "GPEngine",
    products: [
        .library(name: "GPEngine", targets: ["GPEngine"]),
        .library(name: "GPObservable", targets: ["GPObservable"]),
        .library(name: "GPSerialization", targets: ["Serialization"])
    ],
    targets: [
        .target(name: "GPEngine"),
        .target(name: "GPObservable",
                dependencies: ["GPEngine"]),
        .target(name: "Serialization",
                dependencies: ["GPEngine"]),
        .testTarget(name: "GPEngineTests",
                    dependencies: ["GPEngine"]),
        .testTarget(name: "GPObservableTests",
                    dependencies: ["GPEngine", "GPObservable"]),
        .testTarget(name: "SerializationTests",
                    dependencies: ["GPEngine", "Serialization"])
    ],
    swiftLanguageVersions: [.v5]
)
