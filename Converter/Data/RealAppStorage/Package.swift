// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RealAppStorage",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "RealAppStorage",
      targets: ["RealAppStorage"]
    ),
  ],
  dependencies: [
    .package(path: "AppStorageApi"),
    .package(name: "CommonProvider", path: "../Common/CommonProvider"),
    .package(name: "ConverterStorage", path: "../Converter/ConverterData/ConverterStorage"),
    .package(name: "CurrencyStorage", path: "../Currency/CurrencyData/CurrencyStorage"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "RealAppStorage",
      dependencies: [
        "AppStorageApi",
        "ConverterStorage",
        "CurrencyStorage"
      ]
    ),
    .testTarget(
      name: "RealAppStorageTests",
      dependencies: ["RealAppStorage"]
    ),
  ]
)
