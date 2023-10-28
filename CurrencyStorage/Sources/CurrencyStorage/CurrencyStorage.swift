//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import CommonUtils
import CommonStorage
import Foundation
import SwiftData

public protocol CurrencyStorage {
  
  func insertAllRates(_ models: [CurrencyRateStorageModel]) async
  func insertFetchDate(_ model: FetchDateStorageModel) async
  func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError>
  func getInsertDate() async -> FetchDateStorageModel
}

class RealCurrencyStorage: CurrencyStorage {
  private let configuration = ModelConfiguration()
  
  private var container: ModelContainer {
    do {
      return try ModelContainer(
        for: CurrencyRateSwiftDataModel.self, FetchDateSwitfDataModel.self,
        configurations: configuration
      )
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
  func insertAllRates(_ models: [CurrencyRateStorageModel]) async {
    await withContext {
      for model in models {
        $0.insert(model.toSwiftDataModel())
      }
    }
  }
  
  func insertFetchDate(_ model: FetchDateStorageModel) async {
    await withContext {
      $0.insert(model.toSwiftDataModel())
    }
  }
  
  func fetchAllRates() async -> Result<[CurrencyRateStorageModel], StorageError> {
    return await withContext {
      $0.resultFetch(FetchDescriptor<CurrencyRateSwiftDataModel>())
        .map { result in
          result.map { swiftDataModel in
            swiftDataModel.toStorageModel()
          }
        }
    }
  }
  
  func getInsertDate() async -> FetchDateStorageModel {
    return await withContext {
      let result = $0.resultFetch(FetchDescriptor<FetchDateSwitfDataModel>())
      let fetchDateSwiftDataModel = result.getOr(default: []).first ?? FetchDateSwitfDataModel.distantPast
      return fetchDateSwiftDataModel.toStorageModel()
    }
  }
  
  private func withContext<T>(_ f: (ModelContext) -> T) async -> T {
    let context = await container.mainContext
    return f(context)
  }
}
