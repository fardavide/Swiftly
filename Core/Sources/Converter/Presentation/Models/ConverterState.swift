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

public enum ConverterState2 {
  
  case content(content: Content)
  case initial
  case loading
  case error(message: String)
  
  func requireContent() -> ConverterState2.Content {
    switch self {
    case let .content(content): content
    default: fatalError("required Content, but is \(self)")
    }
  }
  
  public struct Content {
    var isRefreshing: Bool
    var searchCurrencies: [Currency]
    var searchQuery: String
    var sorting: CurrencySorting
    var updatedAt: String?
    var values: [CurrencyValue]
  }
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

public extension ConverterState2 {
  
  static let sample = ConverterState2.content(
    isRefreshing: false,
    searchCurrencies: Currency.samples.all(),
    searchQuery: "",
    sorting: .favoritesFirst,
    updatedAt: "2023-12-25 12:44:00 +0000",
    values: CurrencyValue.samples.all()
  )
  
  static func content(
    isRefreshing: Bool,
    searchCurrencies: [Currency],
    searchQuery: String,
    sorting: CurrencySorting,
    updatedAt: String?,
    values: [CurrencyValue]
  ) -> ConverterState2 {
    ConverterState2.content(
      content: ConverterState2.Content(
        isRefreshing: isRefreshing,
        searchCurrencies: searchCurrencies,
        searchQuery: searchQuery,
        sorting: sorting,
        updatedAt: updatedAt,
        values: values
      )
    )
  }
}
