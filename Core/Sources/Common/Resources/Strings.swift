import SwiftUI
import SwiftlyUtils

// swiftlint:disable type_name
public enum S {
  // swiftlint:enable type_name

  case appName
  case changeCurrency
  case currencyWith(currencyName: String)
  case searchCurrency
  case value
}

public prefix func + (_ string: S) -> LocalizedStringKey {
  switch string {
  case let .currencyWith(currencyName): return "CurrencyWithName: \(currencyName)"
  default: break
  }

  let fullString = String(reflecting: string)
  guard let lastDotIndex = fullString.lastIndex(of: ".") else {
    return LocalizedStringKey(fullString.capitalizedFirst)
  }
  return LocalizedStringKey(String(fullString[lastDotIndex...].dropFirst()).capitalizedFirst)
}
