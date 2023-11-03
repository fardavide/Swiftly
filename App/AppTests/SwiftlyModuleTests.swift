import XCTest

import CommonProvider
@testable import App

final class SwiftlyModuleTests: XCTestCase {

    func test_modules() {
      let provider = Provider.require()
      SwiftlyModule().start(with: provider)
    }
}
