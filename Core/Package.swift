// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
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
        "Design",
        "Network",
        "Provider",
        "Resources",
        "ResourcesMacro",
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
    .package(url: "https://github.com/apple/swift-syntax.git", from: Version(509, 0, 0)),
    .package(url: "https://github.com/kean/Nuke", from: Version(12, 2, 0)),
    .package(url: "https://github.com/kishikawakatsumi/swift-power-assert", from: Version(0, 12, 0))
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
      name: "RealppStorageTests",
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
        "DateUtils",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Common/DateUtilsTests"
    ),
    
    // MARK: Design
    .target(
      name: "Design",
      dependencies: [
        "CurrencyDomain"
      ],
      path: "Sources/Common/Design"
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
        "Provider",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Common/ProviderTests"
    ),

    // MARK: Resources
    .target(
      name: "Resources",
      dependencies: [
        "ResourcesMacro",
        "SwiftlyUtils"
      ],
      path: "Sources/Common/Resources/Api"
    ),
    .macro(
      name: "ResourcesMacro",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ],
      path: "Sources/Common/Resources/Macro"
    ),
    .testTarget(
      name: "ResourcesTests",
      dependencies: [
        "Resources",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Common/Resources/ApiTests"
    ),
    .testTarget(
      name: "ResourcesMacroTests",
      dependencies: [
        "ResourcesMacro",
        .product(name: "PowerAssert", package: "swift-power-assert"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
      ],
      path: "Tests/Common/Resources/MacroTests"
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
        "SwiftlyUtils",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Common/UtilsTests"
    ),

    // MARK: - Converter definitions
    // MARK: Converter Data
    .target(
      name: "ConverterData",
      dependencies: [
        "ConverterStorage",
        "CurrencyStorage",
        "Provider"
      ],
      path: "Sources/Converter/Data/Data"
    ),
    .testTarget(
      name: "ConverterDataTests",
      dependencies: [
        "ConverterData",
        .product(name: "PowerAssert", package: "swift-power-assert")
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
        "Design",
        "Provider",
        "Resources",
        .product(name: "Nuke", package: "Nuke"),
        .product(name: "NukeUI", package: "Nuke")
      ],
      path: "Sources/Converter/Presentation"
    ),
    .testTarget(
      name: "ConverterPresentationTests",
      dependencies: [
        "ConverterDomain",
        "ConverterPresentation",
        "SwiftlyTest",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Converter/PresentationTests"
    ),

    // MARK: Converter Storage
    .target(
      name: "ConverterStorage",
      dependencies: [
        "AppStorage",
        "ConverterDomain",
        "SwiftlyStorage"
      ],
      path: "Sources/Converter/Data/Storage"
    ),
    .testTarget(
      name: "ConverterStorageTests",
      dependencies: [
        "ConverterStorage",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Converter/Data/StorageTests"
    ),

    // MARK: - Currency definitions
    // MARK: Currency Api
    .target(
      name: "CurrencyApi",
      dependencies: [
        "CurrencyDomain",
        "DateUtils",
        "Network"
      ],
      path: "Sources/Currency/Data/Api"
    ),
    .testTarget(
      name: "CurrencyApiTests",
      dependencies: [
        "CurrencyApi",
        .product(name: "PowerAssert", package: "swift-power-assert")
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
        "CurrencyData",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Currency/Data/DataTests"
    ),

    // MARK: Currency Domain
    .target(
      name: "CurrencyDomain",
      dependencies: [
        "DateUtils",
        "SwiftlyUtils"
      ],
      path: "Sources/Currency/Domain"
    ),
    .testTarget(
      name: "CurrencyDomainTests",
      dependencies: [
        "CurrencyDomain",
        .product(name: "PowerAssert", package: "swift-power-assert")
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
        "CurrencyStorage",
        .product(name: "PowerAssert", package: "swift-power-assert")
      ],
      path: "Tests/Currency/Data/StorageTests"
    )
  ]
)
