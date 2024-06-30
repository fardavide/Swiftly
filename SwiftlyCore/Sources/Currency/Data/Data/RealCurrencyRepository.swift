import CurrencyApi
import CurrencyDomain
import CurrencyStorage
import DateUtils
import Foundation
import Network
import Store
import SwiftlyStorage
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
    let updateDelta = getCurrentDate.run() % updatedAt
    let shouldRefresh = (forceRefresh && updateDelta > 1.minutes()) || updateDelta > 1.days()
    print("Rates updated at: \(updatedAt), refreshing: \(shouldRefresh)")
    
    return await get(
      shouldFetch: shouldRefresh,
      fetch: await self.fetchRatesFromApi(),
      readCache: await self.fetchRatesFromStorage(updatedAt: updatedAt),
      saveCache: storeRates
    )
  }
  
  public func markCurrencyUsed(_ currency: Currency) async {
    await storage.markCurrencyUsed(code: currency.code)
  }
  
  private func getAllCurrencies(sorting: CurrencySorting) async -> Result<[Currency], DataError> {
    let updatedAt = await storage.getUpdateDate().updatedAt
    let updateDelta = getCurrentDate.run() % updatedAt
    let shouldRefresh = updateDelta > 1.days()
    print("Currencies udpate at: \(updatedAt), refreshing: \(shouldRefresh)")
    
    return await get(
      shouldFetch: shouldRefresh,
      fetch: await self.fetchCurrenciesFromApi(),
      readCache: await self.fetchCurrenciesFromStorage(sorting: sorting),
      saveCache: storeCurrencies
    )
  }

  private func fetchCurrenciesFromApi() async -> Result<[Currency], ApiError> {
    await api.currencies()
      .map { $0.toDomainModels() }
      .onSuccess(storeCurrencies)
  }

  private func fetchCurrenciesFromStorage(sorting: CurrencySorting) async -> Result<[Currency], StorageError> {
    await storage.fetchAllCurrencies(sorting: sorting)
      .flatMap { storageModels in
        switch storageModels.isEmpty {
        case false: .success(storageModels.toDomainModels())
        case true: .failure(.noCache)
        }
      }
  }

  private func fetchRatesFromApi() async -> Result<CurrencyRates, ApiError> {
    await api.latestRates()
      .map { $0.toDomainModel(fallbackUpdateAt: getCurrentDate.run()) }
  }

  private func fetchRatesFromStorage(updatedAt: Date) async -> Result<CurrencyRates, StorageError> {
    await storage.fetchAllRates()
      .flatMap { storageModels in
        switch storageModels.isEmpty {
        case false: .success(storageModels.toDomainModels())
        case true: .failure(.noCache)
        }
      }
      .map { CurrencyRates(items: $0, updatedAt: updatedAt) }
  }

  private func storeCurrencies(currencies: [Currency]) async {
    await storage.insertAllCurrencies(currencies.toStorageModels())
  }

  private func storeRates(rates: CurrencyRates) async {
    await storage.insertAllRates(rates.items.toStorageModels())
    await storage.insertUpdateDate(rates.updatedAt.toCurrencyDateStorageModel())
  }
}
