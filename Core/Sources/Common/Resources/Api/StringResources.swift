import SwiftUI
import SwiftlyUtils

/// Keys for String resources
/// Use with `#string` macro to resolve a `LocalizedStringKey`
public enum StringKey {

  case appName
  case changeCurrency
  case close
  case currencyWith(name: String)
  case favoritesFirst
  case searchCurrency
  case updated(at: String)
  case value
}

/// Resolves a `LocalizedStringKey` from given `key`
@freestanding(expression)
public macro string(_ key: StringKey) -> LocalizedStringKey = #externalMacro(
  module: "ResourcesMacro",
  type: "StringResourcesMacro"
)
