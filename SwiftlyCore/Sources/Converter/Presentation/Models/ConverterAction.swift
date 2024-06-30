import CurrencyDomain

public enum ConverterAction {

  /// Add a Currency in the Converter
  case addAcurrency(currency: Currency)
  
  /// Replace a Currency in the Converter
  case changeCurrency(prev: Currency, new: Currency)
  
  /// Close the View to select a new Currency
  case closeSelectCurrency
  
  /// Open the View to select a new Currency
  case openSelectCurrency(selectedCurrency: Currency?)
  
  /// Refresh the data
  case refresh
  
  /// Remove a Currency from the Converter
  case removeCurrency(currency: Currency)

  /// Search for Currencies
  case searchCurrencies(query: String)
  
  /// Set default sorting for Currencies
  case setSorting(_ sorting: CurrencySorting)

  /// Update a Currency value in the Converter
  case updateValue(currencyValue: CurrencyValue)
}
