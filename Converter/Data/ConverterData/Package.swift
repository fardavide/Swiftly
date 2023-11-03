// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ConverterData",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ConverterData",
      targets: ["ConverterData"]
    ),
  ],
  dependencies: [
    .package(name: "CommonProvider", path: "../Common/CommonProvider"),
    .package(path: "ConverterDomain"),
    .package(path: "ConverterStorage")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ConverterData",
      dependencies: [
        "ConverterStorage"
      ]
    ),
    .testTarget(
      name: "ConverterDataTests",
      dependencies: ["ConverterData"]
    ),
  ]
)
