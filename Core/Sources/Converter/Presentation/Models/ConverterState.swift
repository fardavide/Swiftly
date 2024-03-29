import ConverterDomain
import CurrencyDomain
import Design
import SwiftlyUtils

public struct ConverterState {
  var error: ErrorModel?
  var isLoading: Bool
  var isSelectCurrencyOpen: Bool
  var searchCurrencies: [Currency]
  var searchQuery: String
  var selectedCurrency: Currency?
  var sorting: CurrencySorting
  var updatedAt: String?
  var values: [CurrencyValue]
  
  var canAddCurrency: Bool {
    values.count < SelectedCurrencies.maxItems
  }
  
  var canRemoveCurrency: Bool {
    values.count > 2
  }
}

public extension ConverterState {
  
  static let initial = ConverterState(
    isLoading: true,
    isSelectCurrencyOpen: false,
    searchCurrencies: [],
    searchQuery: "",
    sorting: .favoritesFirst,
    values: []
  )
  
  static let sample = ConverterState(
    isLoading: false,
    isSelectCurrencyOpen: false,
    searchCurrencies: Array(Currency.samples.all().take(5)),
    searchQuery: "",
    sorting: .favoritesFirst,
    updatedAt: "2023-12-25 12:44:00 +0000",
    values: CurrencyValue.samples.all()
  )
}
