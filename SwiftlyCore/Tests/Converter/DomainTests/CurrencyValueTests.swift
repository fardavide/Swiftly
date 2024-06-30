import Testing

@testable import CurrencyDomain

struct CurrencyValueTests {

  @Test func convert() {
    // given
    let input = CurrencyValue(
      value: 10,
      currencyWithRate: .samples.usd
    )

    // when
    let result = input.convert(to: .samples.eur)

    // then
    #expect(result.value == 9)
  }
}
