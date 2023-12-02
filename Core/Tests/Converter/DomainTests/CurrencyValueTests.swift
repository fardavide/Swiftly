import XCTest

import PowerAssert
@testable import CurrencyDomain

final class CurrencyValueTests: XCTestCase {

  func test_convert() {
    // given
    let input = CurrencyValue(
      value: 10,
      currencyWithRate: .samples.usd
    )

    // when
    let result = input.convert(to: .samples.eur)

    // then
    #assert(result.value == 9)
  }
}
