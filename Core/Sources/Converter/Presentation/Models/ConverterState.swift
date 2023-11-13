import CurrencyDomain

public struct ConverterState {
  var error: String?
  var isLoading: Bool
  var searchCurrencies: [Currency]
  var sorting: CurrencySorting
  var values: [CurrencyValue]
}

public extension ConverterState {
  
  static let initial = ConverterState(
    isLoading: true,
    searchCurrencies: [],
    sorting: .favoritesFirst,
    values: []
  )
  
  static let sample = ConverterState(
    isLoading: false,
    searchCurrencies: Currency.samples.all(),
    sorting: .favoritesFirst,
    values: CurrencyValue.samples.all()
  )
}
