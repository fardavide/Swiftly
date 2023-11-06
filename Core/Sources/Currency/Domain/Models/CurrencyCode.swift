public struct CurrencyCode: Comparable, Decodable, Encodable, Hashable, Identifiable {
  public let value: String

  public var id: String {
    value
  }

  public init(value: String) {
    if value.count < CurrencyCode.min || value.count > CurrencyCode.max {
      preconditionFailure(
        "Invalid currency code: expected between \(CurrencyCode.min) and \(CurrencyCode.max) chars, " +
          "but got \(value.count), \(value)"
      )
    }
    self.value = value
  }

  public static func < (lhs: CurrencyCode, rhs: CurrencyCode) -> Bool {
    lhs.value < rhs.value
  }
}

public extension CurrencyCode {

  static let samples = CurrencyCodeSamples()
}

extension CurrencyCode {
  static let min = 2
  static let max = 5
}

public class CurrencyCodeSamples {
  public let chf = CurrencyCode(value: "CHF")
  public let cny = CurrencyCode(value: "CNY")
  public let eur = CurrencyCode(value: "EUR")
  public let gbp = CurrencyCode(value: "GBP")
  public let jpy = CurrencyCode(value: "JPY")
  public let usd = CurrencyCode(value: "USD")
}
