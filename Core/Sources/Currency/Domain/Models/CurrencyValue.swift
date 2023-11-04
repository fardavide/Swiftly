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
  static let samples = CurrencyValueSamples()
  
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

public class CurrencyValueSamples {
  public let eur = CurrencyValue(value: 123_456.071, currencyWithRate: CurrencyWithRate.samples.eur)
  public let usd = CurrencyValue(value: 234_567.8, currencyWithRate: CurrencyWithRate.samples.usd)
  
  public func all() -> [CurrencyValue] {
    [eur, usd]
  }
}
