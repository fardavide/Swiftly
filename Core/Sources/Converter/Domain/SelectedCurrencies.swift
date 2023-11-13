import CurrencyDomain

public struct SelectedCurrencies: Equatable {
  public let currencyCodes: [CurrencyCode]

  fileprivate init(currencyCodes: [CurrencyCode]) {
    if currencyCodes.count != SelectedCurrencies.size {
      preconditionFailure("Required exactly \(SelectedCurrencies.size) currencies")
    }
    self.currencyCodes = currencyCodes
  }
}

public extension SelectedCurrencies {

  static let size = 6

  static let initial = SelectedCurrencies(
    currencyCodes: [
      .samples.eur,
      .samples.usd,
      .samples.gbp,
      .samples.chf,
      .samples.jpy,
      .samples.cny
    ]
  )

  static let samples = FavoriteCurrenciesSamples()

  static func of(currencyCodes: [CurrencyCode]) -> SelectedCurrencies {
    if currencyCodes.count < SelectedCurrencies.size {
      preconditionFailure("Required at least \(SelectedCurrencies.size) currencies")
    }
    return SelectedCurrencies(currencyCodes: Array(currencyCodes[0...size-1]))
  }
}

public class FavoriteCurrenciesSamples {

  public let alphabetical = SelectedCurrencies(
    currencyCodes: [
      .samples.chf,
      .samples.cny,
      .samples.eur,
      .samples.gbp,
      .samples.jpy,
      .samples.usd
    ]
  )
}
