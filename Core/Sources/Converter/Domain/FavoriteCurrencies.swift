import CurrencyDomain

public struct FavoriteCurrencies: Equatable {
  public let currencyCodes: [CurrencyCode]
  
  fileprivate init(currencyCodes: [CurrencyCode]) {
    if currencyCodes.count != FavoriteCurrencies.size {
      preconditionFailure("Required exactly \(FavoriteCurrencies.size) currencies")
    }
    self.currencyCodes = currencyCodes
  }
}

public extension FavoriteCurrencies {
  
  static let size = 6
  
  static let initial = FavoriteCurrencies(
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
  
  static func of(currencyCodes: [CurrencyCode]) -> FavoriteCurrencies {
    if currencyCodes.count < FavoriteCurrencies.size {
      preconditionFailure("Required at least \(FavoriteCurrencies.size) currencies")
    }
    return FavoriteCurrencies(currencyCodes: Array(currencyCodes[0...size-1]))
  }
}

public class FavoriteCurrenciesSamples {
  
  public let alphabetical = FavoriteCurrencies(
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
