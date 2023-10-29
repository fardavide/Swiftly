//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//
import CommonDate
import CommonNetwork
import CommonUtils
import CurrencyApi
import CurrencyDomain
import CurrencyStorage
import Foundation

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
  
  public func getLatestRates() async -> Result<[CurrencyRate], DataError> {
    let updatedAt = await storage.getUpdateDate().updatedAt
    return if getCurrentDate.run() % updatedAt > 1.days() {
      await fetchFromApi()
    } else {
      await fetchFromStorage()
        .recover(await fetchFromApi())
    }
  }
  
  private func fetchFromApi() async -> Result<[CurrencyRate], DataError> {
    let ratesApiModelResult = await api.latest()
    
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
  
  private func fetchFromStorage() async -> Result<[CurrencyRate], DataError> {
    await storage.fetchAllRates()
      .flatMap { storageModels in
        switch storageModels.isEmpty {
        case false: .success(storageModels.toDomainModels())
        case true: .failure(.noCache)
        }
      }
      .mapError { storageError in
        switch storageError {
        case .noCache: .storage
        case .unknown: .storage
        }
      }
  }
  
  private func storeRates(rates: [CurrencyRate], updatedAt: Date) async {
    await storage.insertAllRates(rates.toStorageModels())
    await storage.insertUpdateDate(updatedAt.toCurrencyDateStorageModel())
  }
}
