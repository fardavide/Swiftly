import CurrencyDomain

public struct ConverterState {
  var error: String?
  var isLoading: Bool
  var searchCurrencies: [Currency]
  var values: [CurrencyValue]
}

public extension ConverterState {
  static let initial = ConverterState(
    isLoading: true,
    searchCurrencies: [],
    values: []
  )
  static let sample = ConverterState(
    isLoading: false,
    searchCurrencies: Currency.samples.all(),
    values: CurrencyValue.samples.all()
  )
}
