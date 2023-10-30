//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 30/10/23.
//
import CurrencyDomain

public struct CurrenciesApiModel: Codable {
  public let data: [String: CurrencyApiModel]
}

public struct CurrencyApiModel: Codable {
  let code: String
  let name: String
  let symbol: String
}

public extension CurrenciesApiModel {
  
  static let samples = CurrenciesApiModelSamples()
  
  func toDomainModels() -> [Currency] {
    self.data.map { code, currencyApiModel in
      Currency(
        code: code,
        name: currencyApiModel.name,
        symbol: currencyApiModel.symbol
      )
    }
  }
}

public class CurrenciesApiModelSamples {
  
  public let eurOnly = CurrenciesApiModel(
    data: [
      CurrencyApiModel.samples.eur.code: CurrencyApiModel.samples.eur
    ]
  )
  public let usdOnly = CurrenciesApiModel(
    data: [
      CurrencyApiModel.samples.usd.code: CurrencyApiModel.samples.usd
    ]
  )
  public let all = CurrenciesApiModel(
    data: [
      CurrencyApiModel.samples.eur.code: CurrencyApiModel.samples.eur,
      CurrencyApiModel.samples.usd.code: CurrencyApiModel.samples.usd
    ]
  )
}

public extension CurrencyApiModel {
  
  static let samples = CurrencyApiModelSamples()
  
  func toDomainModel() -> Currency {
    Currency(
      code: code,
      name: name,
      symbol: symbol
    )
  }
}

public class CurrencyApiModelSamples {
  
  let eur = CurrencyApiModel(code: "EUR", name: "Euro", symbol: "€")
  let usd = CurrencyApiModel(code: "USD", name: "US Dollar", symbol: "$")
}
