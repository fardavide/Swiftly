import CommonStorage
import Foundation

public class FakeCurrencyStorage: CurrencyStorage {
  
  private let fetchAllRatesResult: Result<[CurrencyRateStorageModel], StorageError>
  private let fetchDate: FetchDateStorageModel
  
  public init(
    fetchAllRatesResult: Result<[CurrencyRateStorageModel], StorageError> = .failure(.unknown),
    fetchDate: FetchDateStorageModel = FetchDateStorageModel.distantPast
  ) {
    self.fetchAllRatesResult = fetchAllRatesResult
    self.fetchDate = fetchDate
  }
  
  public convenience init(
    fetchAllRatesModels: [CurrencyRateStorageModel],
    fetchDate: FetchDateStorageModel = FetchDateStorageModel.distantPast
  ) {
    self.init(
      fetchAllRatesResult: .success(fetchAllRatesModels),
      fetchDate: fetchDate
    )
  }
  
  public func insertAllRates(_ models: [CurrencyRateStorageModel]) async {}
  
  public func insertFetchDate(_ model: FetchDateStorageModel) async {}
  
  public func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError> {
    fetchAllRatesResult
  }
  
  public func getInsertDate() async -> FetchDateStorageModel {
    fetchDate
  }
}
