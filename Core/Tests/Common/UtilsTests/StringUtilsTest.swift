import XCTest

import PowerAssert
@testable import SwiftlyUtils

final class StringUtilsTest: XCTestCase {

  func test_capitalizeFirst() {
    #assert("hello world. Bye".capitalizedFirst == "Hello world. Bye")
  }
  
  func test_dotCase_fromCamelCase() {
    #assert("helloWorld".dotCase == "hello.world")
  }
}
