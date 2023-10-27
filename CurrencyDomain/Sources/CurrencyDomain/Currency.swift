//
//  Currency.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import Foundation

public enum Currency: CurrencyProtocol {
  case eur
  case usd
  
  public var flag: String {
    switch self {
    case .eur: "🇪🇺"
    case .usd: "🇺🇸"
    }
  }
  
  public var longName: String {
    switch self {
    case .eur: "Euro"
    case .usd: "US Dollar"
    }
  }
  
  public var code: String {
    switch self {
    case .eur: "EUR"
    case .usd: "USD"
    }
  }
  
  public var symbol: String {
    switch self {
    case .eur: "€"
    case .usd: "$"
    }
  }
}

public protocol CurrencyProtocol {
    var flag: String { get }
    var longName: String { get }
    var code: String { get }
    var symbol: String { get }
}

public extension CurrencyProtocol {
  
  var longNameWithSymbol: String {
    "\(self.longName) \(self.symbol)"
  }

  static func from(code: String) -> Currency? {
    switch code {
    case Currency.eur.code:
      return .eur
    case Currency.usd.code:
      return .usd
    default:
      return nil
    }
  }
}
