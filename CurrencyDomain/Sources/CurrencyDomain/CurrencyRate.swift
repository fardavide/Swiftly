//
//  CurrencyWeight.swift
//  App
//
//  Created by Davide Giuseppe Farella on 24/10/23.
//

public struct CurrencyRate: Equatable, Hashable, Identifiable {
  public let currencyCode: String
  public let rate: Double
  
  public init(currencyCode: String, rate: Double) {
    self.currencyCode = currencyCode
    self.rate = rate
  }
  
  public var id: String {
    currencyCode
  }
}

public extension CurrencyRate {
  static let samples = CurrencyRateSamples()
}

public struct CurrencyRateSamples {
  public let eur = CurrencyRate(currencyCode: Currency.samples.eur.code, rate: 1)
  public let usd = CurrencyRate(currencyCode: Currency.samples.usd.code, rate: 0.7)
  
  public func all() -> [CurrencyRate] {
    [eur, usd]
  }
}
