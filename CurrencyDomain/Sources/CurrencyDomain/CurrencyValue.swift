//
//  CurrencyValue.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import Foundation

public struct CurrencyValue: Identifiable, Equatable {
  public let value: Double
  public let currencyRate: CurrencyRate
  
  public init(value: Double, currencyRate: CurrencyRate) {
    self.value = value
    self.currencyRate = currencyRate
  }
  
  public var id: Currency {
    currencyRate.currency
  }
}

public extension CurrencyValue {
  static let samples = [
    CurrencyValue(value: 123_456.071, currencyRate: CurrencyRate.samples.eur),
    CurrencyValue(value: 234_567.8, currencyRate: CurrencyRate.samples.usd)
  ]
}

public extension Double {
  func of(_ currencyWeight: CurrencyRate) -> CurrencyValue {
    CurrencyValue(value: self, currencyRate: currencyWeight)
  }
}
