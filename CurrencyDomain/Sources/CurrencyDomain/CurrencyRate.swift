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

extension CurrencyRate {
  static let samples = CurrencyWeightSamples()
}

struct CurrencyWeightSamples {
  let eur = CurrencyRate(currency: .eur, rate: 1)
  let usd = CurrencyRate(currency: .usd, rate: 0.7)
  
  func of(_ currency: Currency) -> CurrencyRate {
    switch currency {
    case .eur: eur
    case .usd: usd
    }
  }
}
