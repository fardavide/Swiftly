import Foundation
import SwiftlyUtils

public protocol CurrencyRepository: Sendable {

  /// Get `[Currency]` for given `query` and `sorting`, from cache or remote source
  func getCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> DataResult<[Currency]>

  /// Get latest `[CurrencyRate]`, from cache or remote source
  func getLatestRates(forceRefresh: Bool) async -> DataResult<CurrencyRates>

  /// Mark `currency` as used, to increase its popularity (i.e. suggested first)
  func markCurrencyUsed(_ currency: Currency) async
}

public extension CurrencyRepository {

  func getCurrencies(
    query: String = "",
    sorting: CurrencySorting = .alphabetical
  ) async -> DataResult<[Currency]> {
    await getCurrencies(
      query: query,
      sorting: sorting
    )
  }

  func getLatestCurrenciesWithRates(
    query: String = "",
    sorting: CurrencySorting = .alphabetical,
    forceRefresh: Bool = false
  ) async -> DataResult<[CurrencyWithRate]> {
    let currenciesResult = await getCurrencies(query: query, sorting: sorting)
    guard let currencies = currenciesResult.data else {
      return .error(currenciesResult.error!)
    }

    let ratesResult = await getLatestRates(forceRefresh: forceRefresh)
    guard let rates = ratesResult.data else {
      return .error(ratesResult.error!)
    }

    let currenciesWithRates = currencies.compactMap { currency in
      guard let rate = rates.findRate(for: currency.code)?.rate else {
        return nil
      }
      return CurrencyWithRate(
        currency: currency,
        rate: rate
      )
    }

    // Propagate any soft errors from either result
    if let softError = currenciesResult.error ?? ratesResult.error {
      return .successWithError(data: currenciesWithRates, error: softError)
    }
    return .success(currenciesWithRates)
  }

  func markCurrenciesUsed(
    from firstCurrency: Currency,
    to secondCurrency: Currency
  ) async {
    await markCurrencyUsed(firstCurrency)
    await markCurrencyUsed(secondCurrency)
  }
}

public class FakeCurrencyRepository: CurrencyRepository, @unchecked Sendable {

  let currenciesResult: DataResult<[Currency]>
  let currencyRatesResult: DataResult<CurrencyRates>

  public init(
    currenciesResult: DataResult<[Currency]> = .error(.unknown),
    currencyRatesResult: DataResult<CurrencyRates> = .error(.unknown)
  ) {
    self.currenciesResult = currenciesResult
    self.currencyRatesResult = currencyRatesResult
  }

  public convenience init(
    currencies: [Currency]? = nil,
    currencyRates: CurrencyRates? = nil
  ) {
    self.init(
      currenciesResult: currencies != nil ? .success(currencies!) : .error(.unknown),
      currencyRatesResult: currencyRates != nil ? .success(currencyRates!) : .error(.unknown)
    )
  }

  public func getCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> DataResult<[Currency]> {
    currenciesResult.map { currencies in
      currencies.search(by: query)
    }
  }

  public func getLatestRates(forceRefresh: Bool) async -> DataResult<CurrencyRates> {
    currencyRatesResult
  }

  public func markCurrencyUsed(_ currency: Currency) async {}
}
