import XCTest

import Provider
@testable import Swiftly

final class SwiftlyModuleTests: XCTestCase {
  
  func test_modules() {
    let provider = Provider.require()
    SwiftlyModule().start(with: provider)
  }
}
