// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CurrencyStorage",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "CurrencyStorage",
      targets: ["CurrencyStorage"]
    ),
  ],
  dependencies: [
    .package(path: "CurrencyDomain"),
    .package(name: "CommonProvider", path: "../Common/CommonProvider"),
    .package(name: "CommonStorage", path: "../Common/CommonStorage")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CurrencyStorage",
      dependencies: [
        "CommonProvider",
        "CommonStorage"
      ]
    ),
    .testTarget(
      name: "CurrencyStorageTests",
      dependencies: ["CurrencyStorage"]
    )
  ]
)
