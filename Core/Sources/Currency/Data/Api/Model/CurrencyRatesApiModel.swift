import CurrencyDomain
import DateUtils
import Foundation

public protocol CurrencyRatesApiModel {
  func toDomainModel(fallbackUpdateAt: @autoclosure () -> Date) -> CurrencyRates
}

public struct CurrencyRateApiModel: Codable {
  let code: String
  public let value: Double
}

public struct AnyCurrencyRatesApiModel: CurrencyRatesApiModel {
  private let _toDomainModel: (@autoclosure () -> Date) -> CurrencyRates
  
  public init<T: CurrencyRatesApiModel>(_ model: T) {
    _toDomainModel = model.toDomainModel
  }
  
  init(_ domainModel: CurrencyRates) {
    _toDomainModel = { _ in domainModel }
  }
  
  public func toDomainModel(fallbackUpdateAt: @autoclosure () -> Date) -> CurrencyRates {
    _toDomainModel(fallbackUpdateAt())
  }
}

public extension AnyCurrencyRatesApiModel {
  static let samples = CurrencyRatesApiModelSamples()
}

public class CurrencyRatesApiModelSamples {
  
  public let eurOnly = AnyCurrencyRatesApiModel(.samples.eurOnly)
  public let usdOnly = AnyCurrencyRatesApiModel(.samples.usdOnly)
  public let all = AnyCurrencyRatesApiModel(.samples.all)
}
