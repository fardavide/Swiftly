import SwiftUI
import SwiftlyUtils

public enum StringKey {

  case appName
  case changeCurrency
  case currencyWithName(currencyName: String)
  case searchCurrency
  case value
}

public prefix func + (_ string: StringKey) -> LocalizedStringKey {
  switch string {
  case let .currencyWithName(currencyName):
    return LocalizedStringKey("CurrencyWithName: \(currencyName)")
  default:
    let fullString = String(reflecting: string)
    guard let lastDotIndex = fullString.lastIndex(of: ".") else {
      return LocalizedStringKey(fullString.capitalizedFirst)
    }
    return LocalizedStringKey(String(fullString[lastDotIndex...].dropFirst()).capitalizedFirst)
  }
}
