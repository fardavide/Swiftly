//
//  CurrencyWeight.swift
//  App
//
//  Created by Davide Giuseppe Farella on 24/10/23.
//

import Foundation

public struct CurrencyRate: Equatable, Hashable, Identifiable {
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

public extension CurrencyRate {
  static let samples = CurrencyWeightSamples()
}

public struct CurrencyWeightSamples {
  public let eur = CurrencyRate(currency: .eur, rate: 1)
  public let usd = CurrencyRate(currency: .usd, rate: 0.7)
  
  public func all() -> [CurrencyRate] {
    [eur, usd]
  }
  
  func of(_ currency: Currency) -> CurrencyRate {
    switch currency {
    case .eur: eur
    case .usd: usd
    }
  }
}
