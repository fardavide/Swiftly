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
  
  public func getCurrencies(
    query: String,
    sorting: CurrencySorting
  ) async -> Result<[Currency], DataError> {
    await getAllCurrencies(sorting: sorting).map { $0.search(by: query) }
  }

  public func getLatestRates(forceRefresh: Bool) async -> Result<CurrencyRates, DataError> {
    let updatedAt = await storage.getUpdateDate().updatedAt
    let updateAtDelta = getCurrentDate.run() % updatedAt
    let shouldRefresh = (forceRefresh && updateAtDelta > 1.minutes()) || updateAtDelta > 1.days()
    print("Rates updated at: \(updatedAt), refreshing: \(shouldRefresh)")
    return if shouldRefresh {
      await fetchRatesFromApi().print { _ in "Get latest rates from API" }
    } else {
      await fetchRatesFromStorage().map { $0.updatedAt(updatedAt) }
        .print { _ in "Get latest rates from Storage" }
        .recover(await fetchRatesFromApi().print { _ in "Fallback to get latest rates from API" })
    }
  }
  
  public func markCurrenciesUsed(
    from firstCurrency: Currency,
    to secondCurrency: Currency
  ) async {
    await storage.insertCurrencySelected(code: firstCurrency.code)
    await storage.insertCurrencySelected(code: secondCurrency.code)
  }
  
  private func getAllCurrencies(sorting: CurrencySorting) async -> Result<[Currency], DataError> {
    let updateDate = await storage.getUpdateDate()
    let isValid = updateDate.updatedAt > getCurrentDate.run() - 1.days()
    
    let fromStorage = isValid
    ? await fetchCurrenciesFromStorage(sorting: sorting)
    : .failure(DataError.storage(cause: .noCache))
    
    return await fromStorage
      .print { "Get currencies from Storage: \($0.or(default: []).count)" }
      .recover(await fetchCurrenciesFromApi().print { "Get currencies from API: \($0.or(default: []).count)" })
  }

  private func fetchCurrenciesFromApi() async -> Result<[Currency], DataError> {
    await api.currencies()
      .map { $0.toDomainModels() }
      .mapErrorToDataError()
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
    await api.latestRates()
      .map { $0.toDomainModel(fallbackUpdateAt: getCurrentDate.run()) }
      .mapErrorToDataError()
      .onSuccess(storeRates)
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
