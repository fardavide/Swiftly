import Foundation
import SwiftlyUtils

public protocol CurrencyRepository {

  func getCurrencies(sorting: CurrencySorting) async -> Result<[Currency], DataError>
  
  func getLatestRates() async -> Result<[CurrencyRate], DataError>
  
  func searchCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> Result<[Currency], DataError>
}

public extension CurrencyRepository {
  func getCurrencies() async -> Result<[Currency], DataError> {
    await getCurrencies(sorting: .alphabetical)
  }
}

public class FakeCurrencyRepository: CurrencyRepository {

  let currenciesResult: Result<[Currency], DataError>
  let currencyRatesResult: Result<[CurrencyRate], DataError>

  public init(
    currenciesResult: Result<[Currency], DataError> = .failure(.unknown),
    currencyRatesResult: Result<[CurrencyRate], DataError> = .failure(.unknown)
  ) {
    self.currenciesResult = currenciesResult
    self.currencyRatesResult = currencyRatesResult
  }

  public convenience init(
    currencies: [Currency]? = nil,
    currencyRates: [CurrencyRate]? = nil
  ) {
    self.init(
      currenciesResult: currencies != nil ? .success(currencies!) : .failure(.unknown),
      currencyRatesResult: currencyRates != nil ? .success(currencyRates!) : .failure(.unknown)
    )
  }

  public func getCurrencies(sorting: CurrencySorting) async -> Result<[Currency], DataError> {
    currenciesResult
  }
  
  public func getLatestRates() async -> Result<[CurrencyRate], DataError> {
    currencyRatesResult
  }
  
  public func searchCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> Result<[Currency], DataError> {
    currenciesResult.map { currencies in
      currencies.filter { currency in
        currency.name.contains(query) || currency.code.value.contains(query)
      }
    }
  }
}
