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
    .package(name: "AppStorageApi", path: "../AppStorage/AppStorageApi"),
    .package(name: "CommonDate", path: "../Common/CommonDate"),
    .package(name: "CommonProvider", path: "../Common/CommonProvider"),
    .package(name: "CommonStorage", path: "../Common/CommonStorage"),
    .package(path: "CurrencyDomain")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CurrencyStorage",
      dependencies: [
        "CommonDate",
        "CommonProvider",
        "CommonStorage",
        "CurrencyDomain"
      ]
    ),
    .testTarget(
      name: "CurrencyStorageTests",
      dependencies: ["CurrencyStorage"]
    )
  ]
)
