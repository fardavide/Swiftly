//
//  CurrencyValue.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import Foundation

public struct CurrencyValue: Identifiable, Equatable {
  public let value: Double
  public let currencyWithRate: CurrencyWithRate
  
  public init(value: Double, currencyWithRate: CurrencyWithRate) {
    self.value = value
    self.currencyWithRate = currencyWithRate
  }
  
  public var id: Currency {
    currencyWithRate.currency
  }
}

public extension CurrencyValue {
  static let samples = [
    CurrencyValue(value: 123_456.071, currencyWithRate: CurrencyWithRate.samples.eur),
    CurrencyValue(value: 234_567.8, currencyWithRate: CurrencyWithRate.samples.usd)
  ]
  
  var currency: Currency {
    currencyWithRate.currency
  }
  var rate: Double {
    currencyWithRate.rate
  }
}

public extension Double {
  func of(_ currencyWithRate: CurrencyWithRate) -> CurrencyValue {
    CurrencyValue(value: self, currencyWithRate: currencyWithRate)
  }
}
