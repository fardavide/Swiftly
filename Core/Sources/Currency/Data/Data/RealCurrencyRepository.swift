import CurrencyApi
import CurrencyDomain
import CurrencyStorage
import DateUtils
import Foundation
import Network
import SwiftlyUtils

public final class RealCurrencyRepository: CurrencyRepository {

  private let api: CurrencyApi
  private let getCurrentDate: GetCurrentDate
  private let storage: CurrencyStorage

  init(
    api: CurrencyApi,
    getCurrentDate: GetCurrentDate,
    storage: CurrencyStorage
  ) {
    self.api = api
    self.getCurrentDate = getCurrentDate
    self.storage = storage
  }

  public func getCurrencies(sorting: CurrencySorting) async -> Result<[Currency], DataError> {
    let updateDate = await storage.getUpdateDate()
    let isValid = updateDate.updatedAt > getCurrentDate.run() - 1.days()
    
    let fromStorage = isValid
    ? await fetchCurrenciesFromStorage(sorting: sorting)
    : Result.failure(DataError.storage(cause: .noCache))
    
    return await fromStorage
      .print { "Get currencies from Storage: \($0.or(default: []).count)" }
      .recover(await fetchCurrenciesFromApi().print { "Get currencies from API: \($0.or(default: []).count)" })
  }

  public func getLatestRates() async -> Result<CurrencyRates, DataError> {
    let updatedAt = await storage.getUpdateDate().updatedAt
    return if getCurrentDate.run() % updatedAt > 1.days() {
      await fetchRatesFromApi().print(enabled: false) { "Get latest rates from API: \($0)" }
    } else {
      await fetchRatesFromStorage().map { $0.updatedAt(updatedAt) }
        .print(enabled: false) { "Get latest rates from Storage: \($0)" }
        .recover(await fetchRatesFromApi().print(enabled: false) { "Get latest rates from API: \($0)" })
    }
  }

  public func searchCurrencies(
    query q: String,
    sorting: CurrencySorting
  ) async -> Result<[Currency], DataError> {
    let query: String
    let compareOptions: String.CompareOptions
    if q.count > 1 {
      query = q
      compareOptions = [.caseInsensitive]
    } else {
      query = ".*\(q).*"
      compareOptions = [.caseInsensitive, .regularExpression]
    }
    return await getCurrencies(sorting: sorting).map { currencies in
      currencies.filter { currency in
        currency.code.value.range(of: query, options: compareOptions) ??
          currency.name.range(of: query, options: compareOptions) ??
          currency.symbol.range(of: query, options: compareOptions) != nil
      }
    }
  }

  private func fetchCurrenciesFromApi() async -> Result<[Currency], DataError> {
    let currenciesApiModelResult = await api.currencies()

    switch currenciesApiModelResult {

    case let .success(apiModel):
      let domainModels = apiModel.toDomainModels()
      await storeCurrencies(currencies: domainModels)
      return .success(domainModels.sorted { $0.code < $1.code })

    case let .failure(apiError):
      return switch apiError {
      case .unknown: .failure(.network)
      case .jsonError: .failure(.network)
      }
    }
  }

  private func fetchCurrenciesFromStorage(sorting: CurrencySorting) async -> Result<[Currency], DataError> {
    await storage.fetchAllCurrencies(sorting: sorting)
      .flatMap { storageModels in
        switch storageModels.isEmpty {
        case false: .success(storageModels.toDomainModels())
        case true: .failure(.noCache)
        }
      }
      .mapErrorToDataError()
  }

  private func fetchRatesFromApi() async -> Result<CurrencyRates, DataError> {
    let ratesApiModelResult = await api.latestRates()

    switch ratesApiModelResult {

    case let .success(apiModel):
      let domainModels = apiModel.toDomainModel(fallbackUpdateAt: getCurrentDate.run())
      await storeRates(rates: domainModels)
      return .success(domainModels)

    case let .failure(apiError):
      return switch apiError {
      case .unknown: .failure(.network)
      case .jsonError: .failure(.network)
      }
    }
  }

  private func fetchRatesFromStorage() async -> Result<[CurrencyRate], DataError> {
    await storage.fetchAllRates()
      .flatMap { storageModels in
        switch storageModels.isEmpty {
        case false: .success(storageModels.toDomainModels())
        case true: .failure(.noCache)
        }
      }
      .mapErrorToDataError()
  }

  private func storeCurrencies(currencies: [Currency]) async {
    await storage.insertAllCurrencies(currencies.toStorageModels())
  }

  private func storeRates(rates: CurrencyRates) async {
    await storage.insertAllRates(rates.items.toStorageModels())
    await storage.insertUpdateDate(rates.updatedAt.toCurrencyDateStorageModel())
  }
}
