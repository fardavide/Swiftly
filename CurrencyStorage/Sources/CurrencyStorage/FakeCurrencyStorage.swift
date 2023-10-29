import CommonStorage
import Foundation

public class FakeCurrencyStorage: CurrencyStorage {
  
  private let fetchAllRatesResult: Result<[CurrencyRateStorageModel], StorageError>
  private let updateDate: CurrencyDateStorageModel
  
  public init(
    fetchAllRatesResult: Result<[CurrencyRateStorageModel], StorageError> = .failure(.unknown),
    updateDate: CurrencyDateStorageModel = CurrencyDateStorageModel.distantPast
  ) {
    self.fetchAllRatesResult = fetchAllRatesResult
    self.updateDate = updateDate
  }
  
  public convenience init(
    fetchAllRatesModels: [CurrencyRateStorageModel],
    updateDate: CurrencyDateStorageModel = CurrencyDateStorageModel.distantPast
  ) {
    self.init(
      fetchAllRatesResult: .success(fetchAllRatesModels),
      updateDate: updateDate
    )
  }
  
  public func insertAllRates(_ models: [CurrencyRateStorageModel]) async {}
  
  public func insertUpdateDate(_ model: CurrencyDateStorageModel) async {}
  
  public func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError> {
    fetchAllRatesResult
  }
  
  public func getUpdateDate() async -> CurrencyDateStorageModel {
    updateDate
  }
}
