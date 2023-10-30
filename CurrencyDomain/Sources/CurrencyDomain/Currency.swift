//
//  Currency.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import Foundation

public struct Currency: Equatable, Hashable {
  public let code: String
  public let name: String
  public let symbol: String
  
  public init(code: String, name: String, symbol: String) {
    self.code = code
    self.name = name
    self.symbol = symbol
  }
  
  public var flag: String {
    switch code {
    case "EUR": "🇪🇺"
    case "USD": "🇺🇸"
    default: ""
    }
  }
}

public extension Currency {
  
  static let samples = CurrencySamples()
  
  var nameWithSymbol: String {
    "\(self.name) \(self.symbol)"
  }
}

public class CurrencySamples {
  
  public let eur = Currency(code: "EUR", name: "Euro", symbol: "€")
  public let usd = Currency(code: "USD", name: "US Dollar", symbol: "$")
  
  public func all() -> [Currency] {
    [eur, usd]
  }
}
