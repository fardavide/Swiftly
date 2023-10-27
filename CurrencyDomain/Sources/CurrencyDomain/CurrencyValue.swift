//
//  CurrencyValue.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import Foundation

public struct CurrencyValue: Identifiable, Equatable {
  public let value: Double
  public let currencyWeight: CurrencyWeight
  
  public init(value: Double, currencyWeight: CurrencyWeight) {
    self.value = value
    self.currencyWeight = currencyWeight
  }
  
  public var id: Currency {
    currencyWeight.currency
  }
}

public extension CurrencyValue {
  static let samples = [
    CurrencyValue(value: 123_456.071, currencyWeight: CurrencyWeight.samples.eur),
    CurrencyValue(value: 234_567.8, currencyWeight: CurrencyWeight.samples.usd)
  ]
}

public extension Double {
  func of(_ currencyWeight: CurrencyWeight) -> CurrencyValue {
    CurrencyValue(value: self, currencyWeight: currencyWeight)
  }
}
