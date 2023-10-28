// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    path: "Common/Utils",
    name: "CommonUtils",
    platforms: [
      .iOS(.v17),
      .macOS(.v14),
      .tvOS(.v17),
      .watchOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CommonUtils",
            targets: ["CommonUtils"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CommonUtils"
        ),
        .testTarget(
            name: "CommonUtilsTests",
            dependencies: ["CommonUtils"]
        ),
    ]
)