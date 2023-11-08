import XCTest

@testable import Resources

final class StringResourcesTests: XCTestCase {

  func test_resolvesCorrectId() {
    XCTAssertEqual(
      +StringKey.appName,
      "AppName"
    )
  }
  
  func test_resolvedCorrectIdWithArgs() {
    XCTAssertEqual(
      +StringKey.currencyWithName(currencyName: "Eur"),
       "CurrencyWithName: Eur"
    )
  }
}
