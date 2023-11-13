import XCTest

@testable import Resources

final class ImageResourcesTests: XCTestCase {

  func testSfKey_resolvesIdentifier() {
    // given
    let key = SfKey.arrowLeftArrowRight

    // when
    let result = image(key)

    // then
    XCTAssertEqual("arrow.left.arrow.right", result)
  }
}
