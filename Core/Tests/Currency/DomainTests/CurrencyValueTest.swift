import XCTest
@testable import CurrencyDomain

final class CurrencyValueTest: XCTestCase {

  func test_equals() throws {
    let first = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    let second = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    #assert(first == second)
  }

  func test_notEqualsCurrency() throws {
    let first = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    let second = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.usd)
    #assert(first != second)
  }

  func test_notEqualsValue() throws {
    let first = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    let second = CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.eur)
    #assert(first != second)
  }
}
