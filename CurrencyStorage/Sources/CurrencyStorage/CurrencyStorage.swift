import AppStorageApi
import CommonUtils
import CommonStorage
import Foundation
import SwiftData

public protocol CurrencyStorage {
  
  func insertAllCurrencies(_ models: [CurrencyStorageModel]) async
  func insertAllRates(_ models: [CurrencyRateStorageModel]) async
  func insertUpdateDate(_ model: CurrencyDateStorageModel) async
  func fetchAllCurrencies() async -> Result<[CurrencyStorageModel], StorageError>
  func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError>
  func getUpdateDate() async -> CurrencyDateStorageModel
}

class RealCurrencyStorage: AppStorage, CurrencyStorage {
  
  let container: ModelContainer
  
  init(container: ModelContainer) {
    self.container = container
  }
  
  func insertAllCurrencies(_ models: [CurrencyStorageModel]) async {
    await withContext {
      for model in models {
        $0.insert(model.toSwiftDataModel())
      }
    }
  }
  
  func insertAllRates(_ models: [CurrencyRateStorageModel]) async {
    await withContext {
      for model in models {
        $0.insert(model.toSwiftDataModel())
      }
    }
  }
  
  func insertUpdateDate(_ model: CurrencyDateStorageModel) async {
    await withContext {
      $0.insert(model.toSwiftDataModel())
    }
  }
  
  func fetchAllCurrencies() async -> Result<[CurrencyStorageModel], StorageError> {
    await withContext {
      $0.resultFetch(
        FetchDescriptor<CurrencySwiftDataModel>(
          sortBy: [SortDescriptor(\.code)]
        )
      )
      .map { result in
        result.map { swiftDataModel in
          swiftDataModel.toStorageModel()
        }
      }
    }
  }
  
  func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError> {
    await withContext {
      $0.resultFetch(
        FetchDescriptor<CurrencyRateSwiftDataModel>(
          sortBy: [SortDescriptor(\.code)]
        )
      )
        .map { result in
          result.map { swiftDataModel in
            swiftDataModel.toStorageModel()
          }
        }
    }
  }
  
  func getUpdateDate() async -> CurrencyDateStorageModel {
    await withContext {
      let result = $0.resultFetch(FetchDescriptor<CurrencyDateSwiftDataModel>())
      let fetchDateSwiftDataModel = result.getOr(default: []).first ?? CurrencyDateSwiftDataModel.distantPast
      return fetchDateSwiftDataModel.toStorageModel()
    }
  }
}
