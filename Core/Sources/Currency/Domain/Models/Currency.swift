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
    URL(
      string: "https://github.com/Lissy93/currency-flags/blob/master/assets/flags_png_rectangle/" +
      "\(code.value.lowercased()).png?raw=true"
    )
  }

  var nameWithSymbol: String {
    "\(self.name) \(self.symbol)"
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
