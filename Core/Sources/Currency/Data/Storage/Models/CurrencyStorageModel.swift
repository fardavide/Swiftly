import CurrencyDomain
import Foundation
import SwiftData

public struct CurrencyStorageModel {
  let code: CurrencyCode
  let name: String
  let symbol: String
}

@Model
public class CurrencySwiftDataModel {
  @Attribute(.unique) var code: String
  var name: String
  var symbol: String

  init(
    code: String,
    name: String,
    symbol: String
  ) {
    self.code = code
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
      code: code.value,
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
        name: currency.name,
        symbol: currency.symbol
      )
    }
  }
}

extension CurrencySwiftDataModel {
  func toStorageModel() -> CurrencyStorageModel {
    CurrencyStorageModel(
      code: CurrencyCode(value: code),
      name: name,
      symbol: symbol
    )
  }
}

public class CurrencyStorageModelSamples {
  public let chf = CurrencyStorageModel(
    code: Currency.samples.chf.code,
    name: Currency.samples.chf.name,
    symbol: Currency.samples.chf.symbol
  )
  public let cny = CurrencyStorageModel(
    code: Currency.samples.cny.code,
    name: Currency.samples.cny.name,
    symbol: Currency.samples.cny.symbol
  )
  public let eur = CurrencyStorageModel(
    code: Currency.samples.eur.code,
    name: Currency.samples.eur.name,
    symbol: Currency.samples.eur.symbol
  )
  public let gbp = CurrencyStorageModel(
    code: Currency.samples.gbp.code,
    name: Currency.samples.gbp.name,
    symbol: Currency.samples.gbp.symbol
  )
  public let jpy = CurrencyStorageModel(
    code: Currency.samples.jpy.code,
    name: Currency.samples.jpy.name,
    symbol: Currency.samples.jpy.symbol
  )
  public let usd = CurrencyStorageModel(
    code: Currency.samples.usd.code,
    name: Currency.samples.usd.name,
    symbol: Currency.samples.usd.symbol
  )

  public func all() -> [CurrencyStorageModel] {
    [chf, cny, eur, gbp, jpy, usd]
  }
}
