import SwiftUI
import SwiftlyUtils

public enum StringKey {

  case appName
  case changeCurrency
  case currencyWith(name: String)
  case searchCurrency
  case value
}

@freestanding(expression)
public macro string(_ key: StringKey) -> LocalizedStringKey = #externalMacro(
  module: "ResourcesMacro",
  type: "StringResourcesMacro"
)
