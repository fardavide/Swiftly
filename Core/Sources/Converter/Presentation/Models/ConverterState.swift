import CurrencyDomain

public struct ConverterState {
  var error: String?
  var isLoading: Bool
  var searchCurrencies: [Currency]
  var searchQuery: String
  var sorting: CurrencySorting
  var values: [CurrencyValue]
}

public extension ConverterState {
  
  static let initial = ConverterState(
    isLoading: true,
    searchCurrencies: [],
    searchQuery: "",
    sorting: .favoritesFirst,
    values: []
  )
  
  static let sample = ConverterState(
    isLoading: false,
    searchCurrencies: Currency.samples.all(),
    searchQuery: "",
    sorting: .favoritesFirst,
    values: CurrencyValue.samples.all()
  )
}
