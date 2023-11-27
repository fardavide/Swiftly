import XCTest

import SwiftSyntaxMacrosTestSupport
@testable import ResourcesMacro

private let testMacros = ["string": LocalizedStringKeyMacro.self]

final class StringResourcesMacroTests: XCTestCase {

  func test_stringWithoutArgs() {
    assertMacroExpansion(
      #"""
        #string(.appName)
      """#,
      expandedSource: #"""
        LocalizedStringKey("AppName")
      """#,
      macros: testMacros
    )
  }

  func test_stringWithLiteralArg() {
    assertMacroExpansion(
      #"""
        #string(.currencyWithName("Euro"))
      """#,
      expandedSource: #"""
        LocalizedStringKey("CurrencyWithName Euro")
      """#,
      macros: testMacros
    )
  }

  func test_stringWithLabeledLiteralArg() {
    assertMacroExpansion(
      #"""
        #string(.currencyWith(name: "Euro"))
      """#,
      expandedSource: #"""
        LocalizedStringKey("CurrencyWithName Euro")
      """#,
      macros: testMacros
    )
  }

  func test_stringWithLabeledReferenceArg() {
    assertMacroExpansion(
      #"""
        #string(.currencyWith(name: name))
      """#,
      expandedSource: #"""
        LocalizedStringKey("CurrencyWithName \(name)")
      """#,
      macros: testMacros
    )
  }
}
