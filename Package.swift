// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "RVS_BlueThoth",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_14),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "RVS-BlueThoth",
            type: .dynamic,
            targets: ["RVS_BlueThoth"]
        )
    ],
    dependencies: [
        .package(
            url: "git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git",
            from: "1.2.1"
        ),
        .package(
            url: "git@github.com:RiftValleySoftware/RVS_PersistentPrefs.git",
            from: "1.1.1"
        )
    ],
    targets: [
        .target(
            name: "RVS_BlueThoth",
            path: "./src/Source"
        )
    ]
)
