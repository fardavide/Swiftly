import AppStorage
import ConverterDomain
import CurrencyDomain
import Foundation
import SwiftData
import SwiftlyStorage

public protocol ConverterStorage {

  func fetchFavoriteCurrencies() async -> Result<FavoriteCurrenciesStorageModel, StorageError>

  func insertFavoriteCurrencies(_ model: FavoriteCurrenciesStorageModel) async

  func replaceCurrencyAt(position: Int, currency: Currency) async
}

class RealConverterStorage: AppStorage, ConverterStorage {

  let container: ModelContainer

  init(container: ModelContainer) {
    self.container = container
  }

  func fetchFavoriteCurrencies() async -> Result<FavoriteCurrenciesStorageModel, StorageError> {
    await withContext {
      $0.resultFetch(FetchDescriptor<FavoriteCurrenciesSwiftDataModel>()).flatMap { models in
        if let model = models.first {
          .success(model.toStorageModel())
        } else {
          .failure(.noCache)
        }
      }
    }
  }

  func insertFavoriteCurrencies(_ model: FavoriteCurrenciesStorageModel) async {
    await withContext {
      $0.insert(model.toSwiftDataModel())
    }
  }

  func replaceCurrencyAt(position: Int, currency: Currency) async {
    await withContext { context in
      await context.resultFetch(FetchDescriptor<FavoriteCurrenciesSwiftDataModel>())
        .flatMap { value in !value.isEmpty ? .success(value.first!) : .failure(.noCache) }
        .onSuccess { model in
          model.replaceAt(position: position, newValue: currency.code)
        }
        .onFailure { _ in
          context.insert(
            FavoriteCurrenciesSwiftDataModel(
              currencyCodes: [FavoriteCurrencyPosition(value: position): currency.code]
            )
          )
        }
    }
  }
}
