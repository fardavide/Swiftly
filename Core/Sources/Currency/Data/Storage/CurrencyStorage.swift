import AppStorage
import CurrencyDomain
import Foundation
import SwiftData
import SwiftlyStorage
import SwiftlyUtils

public protocol CurrencyStorage {

  func insertAllCurrencies(_ models: [CurrencyStorageModel]) async
  func insertAllRates(_ models: [CurrencyRateStorageModel]) async
  func insertCurrencySelected(code: CurrencyCode) async
  func insertUpdateDate(_ model: CurrencyDateStorageModel) async
  func fetchAllCurrencies(sorting: CurrencySorting) async -> Result<[CurrencyStorageModel], StorageError>
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
  
  func insertCurrencySelected(code: CurrencyCode) async {
    await withContext { context in
      await context.fetchOne(
        FetchDescriptor<CurrencySwiftDataModel>(
          predicate: #Predicate { $0.code == code.value }
        )
      ).onSuccess { currency in currency.selectCount += 1 }
    }
  }

  func insertUpdateDate(_ model: CurrencyDateStorageModel) async {
    await withContext {
      $0.insert(model.toSwiftDataModel())
    }
  }

  func fetchAllCurrencies(sorting: CurrencySorting) async -> Result<[CurrencyStorageModel], StorageError> {
    let sortDescriptors: [SortDescriptor<CurrencySwiftDataModel>] = switch sorting {
    case .alphabetical: [SortDescriptor(\.code)]
    case .favoritesFirst: [SortDescriptor(\.selectCount, order: .reverse), SortDescriptor(\.code)]
    }
    return await withContext {
      $0.fetchAll(FetchDescriptor<CurrencySwiftDataModel>(sortBy: sortDescriptors))
        .map { result in
          result.map { swiftDataModel in
            swiftDataModel.toStorageModel()
          }
        }
    }
  }

  func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError> {
    await withContext {
      $0.fetchAll(
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
      $0.fetchOne(FetchDescriptor<CurrencyDateSwiftDataModel>())
        .or(default: .distantPast)
        .toStorageModel()
    }
  }
}
