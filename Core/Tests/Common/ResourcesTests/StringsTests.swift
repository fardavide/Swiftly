import XCTest

@testable import Resources

final class StringsTests: XCTestCase {

  func test_resolvesCorrectId() {
    XCTAssertEqual(
      +S.AppName,
      "AppName"
    )
  }
}
