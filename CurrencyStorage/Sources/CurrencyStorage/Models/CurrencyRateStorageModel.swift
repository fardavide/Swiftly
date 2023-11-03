import CurrencyDomain
import Foundation
import SwiftData

public struct CurrencyRateStorageModel {
  let code: CurrencyCode
  let rate: Double
}

@Model
public class CurrencyRateSwiftDataModel {
  @Attribute(.unique) var code: String
  var rate: Double
  
  init(
    code: String,
    rate: Double
  ) {
    self.code = code
    self.rate = rate
  }
}

public extension CurrencyRateStorageModel {
  static let samples = CurrencyRateStorageModelSamples()
  
  func toDomainModel() -> CurrencyRate? {
    CurrencyRate(
      currencyCode: code,
      rate: rate
    )
  }
  
  func toSwiftDataModel() -> CurrencyRateSwiftDataModel {
    CurrencyRateSwiftDataModel(
      code: code.value,
      rate: rate
    )
  }
}

public extension [CurrencyRateStorageModel] {
  func toDomainModels() -> [CurrencyRate] {
    compactMap { $0.toDomainModel() }
  }
}

public extension [CurrencyRate] {
  func toStorageModels() -> [CurrencyRateStorageModel] {
    map { currencyRate in
      CurrencyRateStorageModel(
        code: currencyRate.currencyCode,
        rate: currencyRate.rate
      )
    }
  }
}

extension CurrencyRateSwiftDataModel {
  func toStorageModel() -> CurrencyRateStorageModel {
    CurrencyRateStorageModel(
      code: CurrencyCode(value: code),
      rate: rate
    )
  }
}

public class CurrencyRateStorageModelSamples {
  public let eur = CurrencyRateStorageModel(code: .samples.eur, rate: CurrencyRate.samples.eur.rate)
  public let usd = CurrencyRateStorageModel(code: .samples.usd, rate: CurrencyRate.samples.usd.rate)
  
  public func all() -> [CurrencyRateStorageModel] {
    [eur, usd]
  }
}
