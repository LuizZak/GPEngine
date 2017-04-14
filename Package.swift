// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "GPEngine",
    targets: [
        Target(name: "GPEngine"),
        Target(name: "Serialization", dependencies: ["GPEngine"])
    ],
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1,0,0)..<Version(3, .max, .max))
    ]
)
