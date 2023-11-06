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
  
  public func getCurrencies() async -> Result<[Currency], DataError> {
    await fetchCurrenciesFromStorage().print { "Get currencies from Storage: \($0.getOr(default: []).count)" }
      .recover(await fetchCurrenciesFromApi().print { "Get currencies from API: \($0.getOr(default: []).count)" })
  }
  
  public func getLatestRates() async -> Result<[CurrencyRate], DataError> {
    let updatedAt = await storage.getUpdateDate().updatedAt
    return if getCurrentDate.run() % updatedAt > 1.days() {
      await fetchRatesFromApi().print(enabled: false) { "Get latest rates from API: \($0)" }
    } else {
      await fetchRatesFromStorage().print(enabled: false) { "Get latest rates from Storage: \($0)" }
        .recover(await fetchRatesFromApi().print(enabled: false) { "Get latest rates from API: \($0)" })
    }
  }
  
  public func searchCurrencies(query q: String) async -> Result<[Currency], DataError> {
    let query: String
    let compareOptions: String.CompareOptions
    if q.count > 1 {
      query = q
      compareOptions = [.caseInsensitive]
    } else {
      query = ".*\(q).*"
      compareOptions = [.caseInsensitive, .regularExpression]
    }
    return await getCurrencies().map { currencies in
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
  
  private func fetchCurrenciesFromStorage() async -> Result<[Currency], DataError> {
    await storage.fetchAllCurrencies()
      .flatMap { storageModels in
        switch storageModels.isEmpty {
        case false: .success(storageModels.toDomainModels())
        case true: .failure(.noCache)
        }
      }
      .mapErrorToDataError()
  }
  
  private func fetchRatesFromApi() async -> Result<[CurrencyRate], DataError> {
    let ratesApiModelResult = await api.latestRates()
    
    switch ratesApiModelResult {
      
    case let .success(apiModel):
      let domainModels = apiModel.toDomainModels()
      let updatedAt = apiModel.updatedAt() ?? getCurrentDate.run()
      await storeRates(rates: domainModels, updatedAt: updatedAt)
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
  
  private func storeRates(rates: [CurrencyRate], updatedAt: Date) async {
    await storage.insertAllRates(rates.toStorageModels())
    await storage.insertUpdateDate(updatedAt.toCurrencyDateStorageModel())
  }
}