import XCTest

import PowerAssert
@testable import DateUtils

final class DateMathTests: XCTestCase {

  func test_plusDuration() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 29)

    // when
    let result = date + 3.days()

    // then
    #assert(result == Date.of(year: 2023, month: .nov, day: 1))
  }

  func test_minusDuration() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 29)

    // when
    let result = date - 3.days()

    // then
    #assert(result == Date.of(year: 2023, month: .oct, day: 26))
  }

  func test_positiveDistance() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 29)
    let pastDate = Date.of(year: 2023, month: .oct, day: 26)

    // when
    let result = date % pastDate

    // then
    #assert(result == 3.days())
  }

  func test_negativeDistance() throws {
    // given
    let date = Date.of(year: 2023, month: .oct, day: 26)
    let futureDate = Date.of(year: 2023, month: .oct, day: 29)

    // when
    let result = date % futureDate

    // then
    #assert(result == -3.days())
  }
}
