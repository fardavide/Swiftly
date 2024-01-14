import CurrencyDomain

public struct SelectedCurrencies: Equatable {
  public let currencyCodes: [CurrencyCode]

  fileprivate init(currencyCodes: [CurrencyCode]) {
    if currencyCodes.count > SelectedCurrencies.maxItems {
      preconditionFailure("Required at most \(SelectedCurrencies.maxItems) currencies, but has \(currencyCodes.count)")
    }
    self.currencyCodes = currencyCodes
  }
}

public extension SelectedCurrencies {

  static let maxItems = 6

  static let initial = SelectedCurrencies(
    currencyCodes: [
      .samples.eur,
      .samples.usd
    ]
  )

  static let samples = FavoriteCurrenciesSamples()

  static func of(currencyCodes: [CurrencyCode]) -> SelectedCurrencies {
    SelectedCurrencies(currencyCodes: Array(currencyCodes.take(maxItems)))
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
