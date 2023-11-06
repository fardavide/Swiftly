public struct CurrencyWithRate: Equatable, Hashable, Identifiable {
  public let currency: Currency
  public let rate: Double

  public init(currency: Currency, rate: Double) {
    self.currency = currency
    self.rate = rate
  }

  public var id: Currency {
    currency
  }
}

public extension CurrencyWithRate {
  static let samples = CurrencyWithRateSamples()
}

public struct CurrencyWithRateSamples {
  public let chf = CurrencyWithRate(currency: .samples.chf, rate: CurrencyRate.samples.chf.rate)
  public let cny = CurrencyWithRate(currency: .samples.cny, rate: CurrencyRate.samples.cny.rate)
  public let eur = CurrencyWithRate(currency: .samples.eur, rate: CurrencyRate.samples.eur.rate)
  public let gbp = CurrencyWithRate(currency: .samples.gbp, rate: CurrencyRate.samples.gbp.rate)
  public let jpy = CurrencyWithRate(currency: .samples.jpy, rate: CurrencyRate.samples.jpy.rate)
  public let usd = CurrencyWithRate(currency: .samples.usd, rate: CurrencyRate.samples.usd.rate)

  public func all() -> [CurrencyWithRate] {
    [chf, cny, eur, gbp, jpy, usd]
  }
}
