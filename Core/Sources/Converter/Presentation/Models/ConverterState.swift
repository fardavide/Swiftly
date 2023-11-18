import CurrencyDomain

public struct ConverterState {
  var error: String?
  var isLoading: Bool
  var searchCurrencies: [Currency]
  var searchQuery: String
  var sorting: CurrencySorting
  var updatedAt: String?
  var values: [CurrencyValue]
}

public extension ConverterState {
  
  static let initial = ConverterState(
    isLoading: true,
    searchCurrencies: [],
    searchQuery: "",
    sorting: .favoritesFirst,
    updatedAt: nil,
    values: []
  )
  
  static let sample = ConverterState(
    isLoading: false,
    searchCurrencies: Currency.samples.all(),
    searchQuery: "",
    sorting: .favoritesFirst,
    updatedAt: "2023-12-25 12:44:00 +0000",
    values: CurrencyValue.samples.all()
  )
}
