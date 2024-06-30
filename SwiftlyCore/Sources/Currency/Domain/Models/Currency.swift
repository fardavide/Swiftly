import Foundation

public struct Currency: Hashable {
  public let code: CurrencyCode
  public let name: String
  public let symbol: String

  public init(code: CurrencyCode, name: String, symbol: String) {
    self.code = code
    self.name = name
    self.symbol = symbol
  }
}

public extension Currency {

  static let samples = CurrencySamples()

  var flagUrl: URL? {
    getFlagUrl(for: code, size: .w150)
  }

  var nameWithSymbol: String {
    "\(self.name) \(self.symbol)"
  }
}

public extension [Currency] {
  /// Filter `Currency`s using `by` query
  /// - Parameter q: the query to filter by
  /// - Returns: filtered `[Currency]`
  func search(by q: String) -> [Currency] {
    let query: String
    let compareOptions: String.CompareOptions
    if q.count > 1 {
      query = q
      compareOptions = [.caseInsensitive]
    } else {
      query = ".*\(q).*"
      compareOptions = [.caseInsensitive, .regularExpression]
    }
    return filter { currency in
      currency.code.value.range(of: query, options: compareOptions) ??
      currency.name.range(of: query, options: compareOptions) ??
      currency.symbol.range(of: query, options: compareOptions) != nil
    }
  }
}

public class CurrencySamples {

  public let chf = Currency(code: .samples.chf, name: "Swiss Franc", symbol: "CHF")
  public let cny = Currency(code: .samples.cny, name: "Chinese Yuan", symbol: "CN¥")
  public let eur = Currency(code: .samples.eur, name: "Euro", symbol: "€")
  public let gbp = Currency(code: .samples.gbp, name: "British Pound Sterling", symbol: "£")
  public let jpy = Currency(code: .samples.jpy, name: "Japanese Yen", symbol: "¥")
  public let usd = Currency(code: .samples.usd, name: "US Dollar", symbol: "$")

  public func all() -> [Currency] {
    [chf, cny, eur, gbp, jpy, usd]
  }
}
