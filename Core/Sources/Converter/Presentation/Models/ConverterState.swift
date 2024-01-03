import CurrencyDomain

public struct ConverterState {
  var error: String?
  var isAboutOpen: Bool
  var isLoading: Bool
  var isSelectCurrencyOpen: Bool
  var searchCurrencies: [Currency]
  var searchQuery: String
  var selectedCurrency: Currency?
  var sorting: CurrencySorting
  var updatedAt: String?
  var values: [CurrencyValue]
}

public extension ConverterState {
  func requireSelectedCurrency() -> Currency {
    if let currency = selectedCurrency {
      currency
    } else {
      fatalError("Required selected Currency, but was nil")
    }
  }
}

public extension ConverterState {
  
  static let initial = ConverterState(
    isAboutOpen: false,
    isLoading: true,
    isSelectCurrencyOpen: false,
    searchCurrencies: [],
    searchQuery: "",
    sorting: .favoritesFirst,
    values: []
  )
  
  static let sample = ConverterState(
    isAboutOpen: false,
    isLoading: false,
    isSelectCurrencyOpen: false,
    searchCurrencies: Currency.samples.all(),
    searchQuery: "",
    sorting: .favoritesFirst,
    updatedAt: "2023-12-25 12:44:00 +0000",
    values: CurrencyValue.samples.all()
  )
}
