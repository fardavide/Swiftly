import Foundation
import SwiftlyStorage

public class FakeCurrencyStorage: CurrencyStorage {
  
  private let fetchAllCurrenciesResult: Result<[CurrencyStorageModel], StorageError>
  private let fetchAllRatesResult: Result<[CurrencyRateStorageModel], StorageError>
  private let updateDate: CurrencyDateStorageModel
  
  public init(
    fetchAllCurrenciesResult: Result<[CurrencyStorageModel], StorageError> = .failure(.unknown),
    fetchAllRatesResult: Result<[CurrencyRateStorageModel], StorageError> = .failure(.unknown),
    updateDate: CurrencyDateStorageModel = CurrencyDateStorageModel.distantPast
  ) {
    self.fetchAllCurrenciesResult = fetchAllCurrenciesResult
    self.fetchAllRatesResult = fetchAllRatesResult
    self.updateDate = updateDate
  }
  
  public convenience init(
    fetchAllCurrenciesModels: [CurrencyStorageModel],
    fetchAllRatesModels: [CurrencyRateStorageModel],
    updateDate: CurrencyDateStorageModel = CurrencyDateStorageModel.distantPast
  ) {
    self.init(
      fetchAllCurrenciesResult: .success(fetchAllCurrenciesModels),
      fetchAllRatesResult: .success(fetchAllRatesModels),
      updateDate: updateDate
    )
  }
  
  public func insertAllCurrencies(_ models: [CurrencyStorageModel]) async {}
  
  public func insertAllRates(_ models: [CurrencyRateStorageModel]) async {}
  
  public func insertUpdateDate(_ model: CurrencyDateStorageModel) async {}
  
  public func fetchAllCurrencies() async -> Result<[CurrencyStorageModel], StorageError> {
    fetchAllCurrenciesResult
  }
  
  public func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError> {
    fetchAllRatesResult
  }
  
  public func getUpdateDate() async -> CurrencyDateStorageModel {
    updateDate
  }
}
