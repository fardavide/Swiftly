import Foundation

public struct CurrencyRate: Hashable, Identifiable {
  public let currencyCode: CurrencyCode
  public let rate: Double

  public init(currencyCode: CurrencyCode, rate: Double) {
    self.currencyCode = currencyCode
    self.rate = rate
  }

  public var id: CurrencyCode {
    currencyCode
  }
}

public extension CurrencyRate {
  static let samples = CurrencyRateSamples()
}

public struct CurrencyRateSamples {
  public let chf = CurrencyRate(currencyCode: .samples.chf, rate: 0.9)
  public let cny = CurrencyRate(currencyCode: .samples.cny, rate: 7.3)
  public let eur = CurrencyRate(currencyCode: .samples.eur, rate: 0.9)
  public let gbp = CurrencyRate(currencyCode: .samples.gbp, rate: 0.8)
  public let jpy = CurrencyRate(currencyCode: .samples.jpy, rate: 150)
  public let usd = CurrencyRate(currencyCode: .samples.usd, rate: 1.0)

  public func all() -> [CurrencyRate] {
    [chf, cny, eur, gbp, jpy, usd]
  }
}

public extension [CurrencyRate] {
  
  func updatedAt(_ date: Date) -> CurrencyRates {
    CurrencyRates(items: self, updatedAt: date)
  }
}
