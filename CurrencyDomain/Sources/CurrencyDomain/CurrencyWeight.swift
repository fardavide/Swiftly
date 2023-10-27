//
//  CurrencyWeight.swift
//  App
//
//  Created by Davide Giuseppe Farella on 24/10/23.
//

import Foundation

public struct CurrencyWeight: Equatable, Hashable, Identifiable {
  public let currency: Currency
  public let weigth: Double
  
  public init(currency: Currency, weigth: Double) {
    self.currency = currency
    self.weigth = weigth
  }
  
  public var id: Currency {
    currency
  }
}

extension CurrencyWeight {
  static let samples = CurrencyWeightSamples()
}

struct CurrencyWeightSamples {
  let eur = CurrencyWeight(currency: .eur, weigth: 1)
  let usd = CurrencyWeight(currency: .usd, weigth: 0.7)
  
  func of(_ currency: Currency) -> CurrencyWeight {
    switch currency {
    case .eur: eur
    case .usd: usd
    }
  }
}
