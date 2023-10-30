//
//  CurrencyWeight.swift
//  App
//
//  Created by Davide Giuseppe Farella on 24/10/23.
//

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
  public let eur = CurrencyWithRate(currency: Currency.samples.eur, rate: 1)
  public let usd = CurrencyWithRate(currency: Currency.samples.usd, rate: 0.7)
  
  public func all() -> [CurrencyWithRate] {
    [eur, usd]
  }
}
