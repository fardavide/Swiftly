import CurrencyDomain

public enum ConverterAction {

  /// Replace a Currency in the Converter
  case changeCurrency(prev: Currency, new: Currency)

  /// Search for Currencies
  case searchCurrencies(query: String)
  
  /// Set default sorting for Currencies
  case setSorting(_ sorting: CurrencySorting)

  /// Update a Currency value in the Converter
  case updateValue(currencyValue: CurrencyValue)
}
