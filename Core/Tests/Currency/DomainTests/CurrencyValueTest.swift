import Testing
@testable import CurrencyDomain

struct CurrencyValueTest {

  @Test
  func equals() throws {
    let first = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    let second = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    #expect(first == second)
  }

  @Test
  func notEqualsCurrency() throws {
    let first = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    let second = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.usd)
    #expect(first != second)
  }

  @Test
  func notEqualsValue() throws {
    let first = CurrencyValue(value: 10, currencyWithRate: CurrencyWithRate.samples.eur)
    let second = CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.eur)
    #expect(first != second)
  }
}
