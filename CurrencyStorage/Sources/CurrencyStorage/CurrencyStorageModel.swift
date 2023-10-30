//
//  File.swift
//
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//
import CurrencyDomain
import Foundation
import SwiftData

public struct CurrencyStorageModel {
  let code: String
  let flag: String
  let name: String
  let symbol: String
}

@Model
public class CurrencySwiftDataModel {
  @Attribute(.unique) var code: String
  var flag: String
  var name: String
  var symbol: String
  
  init(
    code: String,
    flag: String,
    name: String,
    symbol: String
  ) {
    self.code = code
    self.flag = flag
    self.name = name
    self.symbol = symbol
  }
}

public extension CurrencyStorageModel {
  static let samples = CurrencyStorageModelSamples()
  
  func toDomainModel() -> Currency? {
    Currency(
      code: code,
      name: name,
      symbol: symbol
    )
  }
  
  func toSwiftDataModel() -> CurrencySwiftDataModel {
    CurrencySwiftDataModel(
      code: code,
      flag: flag,
      name: name,
      symbol: symbol
    )
  }
}

public extension [CurrencyStorageModel] {
  func toDomainModels() -> [Currency] {
    compactMap { $0.toDomainModel() }
  }
}

public extension [Currency] {
  func toStorageModels() -> [CurrencyStorageModel] {
    map { currency in
      CurrencyStorageModel(
        code: currency.code,
        flag: currency.flag,
        name: currency.name,
        symbol: currency.symbol
      )
    }
  }
}

extension CurrencySwiftDataModel {
  func toStorageModel() -> CurrencyStorageModel {
    CurrencyStorageModel(
      code: code,
      flag: flag,
      name: name,
      symbol: symbol
    )
  }
}

public class CurrencyStorageModelSamples {
  public let eur = CurrencyStorageModel(
    code: Currency.samples.eur.code,
    flag: Currency.samples.eur.flag,
    name: Currency.samples.eur.name,
    symbol: Currency.samples.eur.symbol
  )
  public let usd = CurrencyStorageModel(
    code: Currency.samples.usd.code,
    flag: Currency.samples.usd.flag,
    name: Currency.samples.usd.name,
    symbol: Currency.samples.usd.symbol
  )
  
  public func all() -> [CurrencyStorageModel] {
    [eur, usd]
  }
}
