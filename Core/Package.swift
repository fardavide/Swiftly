// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Core",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .tvOS(.v17),
    .watchOS(.v10)
  ],
  products: [
    .library(
      name: "Core",
      targets: [
        // MARK: - App Storage declaration
        "AppStorage",
        "RealAppStorage",
        // MARK: - Common declaration
        "DateUtils",
        "Network",
        "Provider",
        "SwiftlyStorage",
        "SwiftlyTest",
        "SwiftlyUtils",
        // MARK: - Converter declartion
        "ConverterData",
        "ConverterDomain",
        "ConverterPresentation",
        "ConverterStorage",
        // MARK: - Currency declaration
        "CurrencyApi",
        "CurrencyData",
        "CurrencyDomain",
        "CurrencyStorage"
      ]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/kean/Nuke", from: Version(12, 1, 6))
  ],
  targets: [

    // MARK: - App Storage definition
    // MARK: App Storage
    .target(
      name: "AppStorage",
      dependencies: [],
      path: "Sources/AppStorage/Api"
    ),
    .testTarget(
      name: "AppStorageTests",
      dependencies: [
        "AppStorage"
      ],
      path: "Tests/AppStorage/ApiTests"
    ),

    // MARK: Real App Storage
    .target(
      name: "RealAppStorage",
      dependencies: [
        "AppStorage",
        "ConverterStorage",
        "CurrencyStorage",
        "Provider"
      ],
      path: "Sources/AppStorage/Real"
    ),
    .testTarget(
      name: "ARealppStorageTests",
      dependencies: [
        "RealAppStorage"
      ],
      path: "Tests/AppStorage/RealTests"
    ),

    // MARK: - Common definitions
    // MARK: Date Utils
    .target(
      name: "DateUtils",
      dependencies: [
        "Provider"
      ],
      path: "Sources/Common/DateUtils"
    ),
    .testTarget(
      name: "DateUtilsTest",
      dependencies: [
        "DateUtils"
      ],
      path: "Tests/Common/DateUtilsTests"
    ),

    // MARK: Network
    .target(
      name: "Network",
      path: "Sources/Common/Network"
    ),
    .testTarget(
      name: "NetworkTests",
      dependencies: [
        "Network"
      ],
      path: "Tests/Common/NetworkTests"
    ),

    // MARK: Provider
    .target(
      name: "Provider",
      path: "Sources/Common/Provider"
    ),
    .testTarget(
      name: "ProviderTests",
      dependencies: [
        "Provider"
      ],
      path: "Tests/Common/ProviderTests"
    ),

    // MARK: Storage
    .target(
      name: "SwiftlyStorage",
      dependencies: [
        "SwiftlyUtils"
      ],
      path: "Sources/Common/Storage"
    ),
    .testTarget(
      name: "StorageTests",
      dependencies: [
        "SwiftlyStorage"
      ],
      path: "Tests/Common/StorageTests"
    ),

    // MARK: Test
    .target(
      name: "SwiftlyTest",
      path: "Sources/Common/Test"
    ),
    .testTarget(
      name: "TestTests",
      dependencies: [
        "SwiftlyTest"
      ],
      path: "Tests/Common/TestTests"
    ),

    // MARK: Utils
    .target(
      name: "SwiftlyUtils",
      path: "Sources/Common/Utils"
    ),
    .testTarget(
      name: "SwiftlyUtilsTests",
      dependencies: [
        "SwiftlyUtils"
      ],
      path: "Tests/Common/UtilsTests"
    ),

    // MARK: - Converter definitions
    // MARK: Converter Data
    .target(
      name: "ConverterData",
      dependencies: [
        "ConverterStorage",
        "Provider"
      ],
      path: "Sources/Converter/Data/Data"
    ),
    .testTarget(
      name: "ConverterDataTests",
      dependencies: [
        "ConverterData"
      ],
      path: "Tests/Converter/Data/DataTests"
    ),

    // MARK: Converter Domain
    .target(
      name: "ConverterDomain",
      dependencies: [
        "CurrencyDomain"
      ],
      path: "Sources/Converter/Domain"
    ),
    .testTarget(
      name: "ConverterDomainTests",
      dependencies: [
        "ConverterDomain"
      ],
      path: "Tests/Converter/DomainTests"
    ),

    // MARK: Converter Presentation
    .target(
      name: "ConverterPresentation",
      dependencies: [
        "ConverterDomain",
        "Provider",
        .product(name: "Nuke", package: "Nuke")
      ],
      path: "Sources/Converter/Presentation"
    ),
    .testTarget(
      name: "ConverterPresentationTests",
      dependencies: [
        "ConverterPresentation"
      ],
      path: "Tests/Converter/PresentationTests"
    ),

    // MARK: Converter Storage
    .target(
      name: "ConverterStorage",
      dependencies: [
        "ConverterDomain"
      ],
      path: "Sources/Converter/Data/Storage"
    ),
    .testTarget(
      name: "ConverterStorageTests",
      dependencies: [
        "ConverterStorage"
      ],
      path: "Tests/Converter/Data/StorageTests"
    ),

    // MARK: - Currency definitions
    // MARK: Currency Api
    .target(
      name: "CurrencyApi",
      dependencies: [
        "CurrencyDomain",
        "Network"
      ],
      path: "Sources/Currency/Data/Api"
    ),
    .testTarget(
      name: "CurrencyApiTests",
      dependencies: [
        "CurrencyApi"
      ],
      path: "Tests/Currency/Data/ApiTests"
    ),

    // MARK: Currency Data
    .target(
      name: "CurrencyData",
      dependencies: [
        "CurrencyApi",
        "CurrencyDomain",
        "CurrencyStorage"
      ],
      path: "Sources/Currency/Data/Data"
    ),
    .testTarget(
      name: "CurrencyDataTests",
      dependencies: [
        "CurrencyData"
      ],
      path: "Tests/Currency/Data/DataTests"
    ),

    // MARK: Currency Domain
    .target(
      name: "CurrencyDomain",
      dependencies: [
        "SwiftlyUtils"
      ],
      path: "Sources/Currency/Domain"
    ),
    .testTarget(
      name: "CurrencyDomainTests",
      dependencies: [
        "CurrencyDomain"
      ],
      path: "Tests/Currency/DomainTests"
    ),

    // MARK: Currency Storage
    .target(
      name: "CurrencyStorage",
      dependencies: [
        "AppStorage",
        "DateUtils",
        "CurrencyDomain",
        "SwiftlyStorage"
      ],
      path: "Sources/Currency/Data/Storage"
    ),
    .testTarget(
      name: "CurrencyStorageTests",
      dependencies: [
        "CurrencyStorage"
      ],
      path: "Tests/Currency/Data/StorageTests"
    )
  ]
)
