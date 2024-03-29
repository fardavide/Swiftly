import Foundation
import SwiftlyUtils

public protocol CurrencyRepository {

  /// Get `[Currency]` for given `query` and `sorting`, from cache or remote source
  func getCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> Result<[Currency], DataError>
  
  /// Get latest `[CurrencyRate]`, from cache or remote source
  func getLatestRates(forceRefresh: Bool) async -> Result<CurrencyRates, DataError>
  
  /// Mark `currency` as used, to increase its popularity (i.e. suggested first)
  func markCurrencyUsed(_ currency: Currency) async
}

public extension CurrencyRepository {
  
  func getCurrencies(
    query: String = "",
    sorting: CurrencySorting = .alphabetical
  ) async -> Result<[Currency], DataError> {
    await getCurrencies(
      query: query,
      sorting: sorting
    )
  }
  
  func getLatestCurrenciesWithRates(
    query: String = "",
    sorting: CurrencySorting = .alphabetical,
    forceRefresh: Bool = false
  ) async -> Result<[CurrencyWithRate], DataError> {
    let currenciesResult = await getCurrencies(query: query, sorting: sorting)
    guard let currencies = currenciesResult.orNil() else {
      return .failure(currenciesResult.requireFailure())
    }
    
    let ratesResult = await getLatestRates(forceRefresh: forceRefresh)
    guard let rates = ratesResult.orNil() else {
      return .failure(ratesResult.requireFailure())
    }
    
    return .success(
      currencies.compactMap { currency in
        guard let rate = rates.findRate(for: currency.code)?.rate else {
          return nil
        }
        return CurrencyWithRate(
          currency: currency,
          rate: rate
        )
      }
    )
  }
  
  func markCurrenciesUsed(
    from firstCurrency: Currency,
    to secondCurrency: Currency
  ) async {
    await markCurrencyUsed(firstCurrency)
    await markCurrencyUsed(secondCurrency)
  }
}

public class FakeCurrencyRepository: CurrencyRepository {

  let currenciesResult: Result<[Currency], DataError>
  let currencyRatesResult: Result<CurrencyRates, DataError>

  public init(
    currenciesResult: Result<[Currency], DataError> = .failure(.unknown),
    currencyRatesResult: Result<CurrencyRates, DataError> = .failure(.unknown)
  ) {
    self.currenciesResult = currenciesResult
    self.currencyRatesResult = currencyRatesResult
  }

  public convenience init(
    currencies: [Currency]? = nil,
    currencyRates: CurrencyRates? = nil
  ) {
    self.init(
      currenciesResult: currencies != nil ? .success(currencies!) : .failure(.unknown),
      currencyRatesResult: currencyRates != nil ? .success(currencyRates!) : .failure(.unknown)
    )
  }

  public func getCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> Result<[Currency], DataError> {
    currenciesResult.map { currencies in
      currencies.search(by: query)
    }
  }
  
  public func getLatestRates(forceRefresh: Bool) async -> Result<CurrencyRates, DataError> {
    currencyRatesResult
  }
  
  public func markCurrencyUsed(_ currency: Currency) async {}
}
