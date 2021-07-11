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
        .library(name: "RVS-BlueThoth",
                 targets: [
                    "RVS_BlueThoth"
                    ]
        )
    ],
    dependencies: [
        .package(name: "RVS_Generic_Swift_Toolbox", url: "git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git", from: "1.6.2")
    ],
    targets: [
        .target(
            name: "RVS_BlueThoth",
            dependencies: [
                .product(name: "RVS-Generic-Swift-Toolbox", package: "RVS_Generic_Swift_Toolbox")
            ])
    ]
)
