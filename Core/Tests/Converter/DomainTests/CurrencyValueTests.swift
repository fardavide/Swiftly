import XCTest

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
    XCTAssertEqual(9, result.value)
  }
}
