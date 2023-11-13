import XCTest

@testable import SwiftlyUtils

final class StringUtilsTest: XCTestCase {

  func test_capitalizeFirst() {
    XCTAssertEqual("hello world. Bye".capitalizedFirst, "Hello world. Bye")
  }
  
  func test_dotCase_fromCamelCase() {
    XCTAssertEqual("helloWorld".dotCase, "hello.world")
  }
}
