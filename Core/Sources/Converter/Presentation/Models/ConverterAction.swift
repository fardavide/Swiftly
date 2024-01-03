import CurrencyDomain

public enum ConverterAction {

  /// Replace a Currency in the Converter
  case changeCurrency(prev: Currency, new: Currency)
  
  /// Close Abouit screen
  case closeAbout
  
  /// Close the View to select a new Currency
  case closeSelectCurrency
  
  /// Open About screen
  case openAbout
  
  /// Open the View to select a new Currency
  case openSelectCurrency(selectedCurrency: Currency)
  
  /// Refresh the data
  case refresh

  /// Search for Currencies
  case searchCurrencies(query: String)
  
  /// Set default sorting for Currencies
  case setSorting(_ sorting: CurrencySorting)

  /// Update a Currency value in the Converter
  case updateValue(currencyValue: CurrencyValue)
}
