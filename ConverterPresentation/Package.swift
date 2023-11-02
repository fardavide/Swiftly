// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ConverterPresentation",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ConverterPresentation",
      targets: ["ConverterPresentation"]
    ),
  ],
  dependencies: [
    .package(name: "CommonTest", path: "../Common/CommonTest"),
    .package(path: "ConverterDomain"),
    .package(name: "CurrencyDomain", path: "../Currency/CurrencyDomain")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "ConverterPresentation",
      dependencies: [
        "CurrencyDomain"
      ]
    ),
    .testTarget(
      name: "ConverterPresentationTests",
      dependencies: [
        "CommonTest",
        "ConverterPresentation"
      ]
    ),
  ]
)
