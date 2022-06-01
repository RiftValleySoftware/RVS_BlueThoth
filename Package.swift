// swift-tools-version:5.5

/*
© Copyright 2020-2022, The Great Rift Valley Software Company

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
*/

import PackageDescription

let package = Package(
    name: "RVS_BlueThoth",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v11),
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
        .package(name: "RVS_Generic_Swift_Toolbox", url: "git@github.com:RiftValleySoftware/RVS_Generic_Swift_Toolbox.git", from: "1.8.1")
    ],
    targets: [
        .target(
            name: "RVS_BlueThoth",
            dependencies: [.product(name: "RVS_Generic_Swift_Toolbox", package: "RVS_Generic_Swift_Toolbox")]
            )
    ]
)
