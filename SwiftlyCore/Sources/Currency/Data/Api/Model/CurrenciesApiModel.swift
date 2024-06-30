import CurrencyDomain

public protocol CurrenciesApiModel {
  func toDomainModels() -> [Currency]
}

public struct AnyCurrenciesApiModel: CurrenciesApiModel {
  private let _toDomainModels: () -> [Currency]
  
  public init<T: CurrenciesApiModel>(_ model: T) {
    _toDomainModels = model.toDomainModels
  }
  
  init(_ domainModels: [Currency]) {
    _toDomainModels = { domainModels }
  }
  
  public func toDomainModels() -> [Currency] {
    _toDomainModels()
  }
}

public extension AnyCurrenciesApiModel {
  static let samples = CurrenciesApiModelSamples()
}

public class CurrenciesApiModelSamples {
  
  public let eurOnly = AnyCurrenciesApiModel([.samples.eur])
  public let usdOnly = AnyCurrenciesApiModel([.samples.usd])
  public let all = AnyCurrenciesApiModel(Currency.samples.all())
}
