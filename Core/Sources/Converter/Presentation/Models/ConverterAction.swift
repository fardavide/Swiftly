import CurrencyDomain

public enum ConverterAction {
  
  /// Called when the use changes a Currency
  case currencyChange(prev: Currency, new: Currency)
  
  /// Called when the use search a Currency
  case searchCurrencies(query: String)
  
  /// Called when the user updates some value for a given Currency
  case valueUpdate(currencyValue: CurrencyValue)
}
