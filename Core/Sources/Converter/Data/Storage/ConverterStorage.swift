import AppStorage
import ConverterDomain
import CurrencyDomain
import Foundation
import SwiftData
import SwiftlyStorage

public protocol ConverterStorage {

  func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError>

  func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async

  func replaceCurrencyAt(position: Int, currency: Currency) async
}

public final class FakeConverterStorage: ConverterStorage {
  
  public init() {
    
  }
  
  public func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError> {
    fatalError("not implemented")
  }
  
  public func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async {}
  
  public func replaceCurrencyAt(position: Int, currency: CurrencyDomain.Currency) async {}
}

class RealConverterStorage: AppStorage, ConverterStorage {

  let container: ModelContainer

  init(container: ModelContainer) {
    self.container = container
  }

  func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError> {
    await withContext {
      $0.fetchAll(FetchDescriptor<FavoriteCurrenciesSwiftDataModel>()).flatMap { models in
        if let model = models.first {
          .success(model.toStorageModel())
        } else {
          .failure(.noCache)
        }
      }
    }
  }

  func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async {
    await withContext {
      $0.insert(model.toSwiftDataModel())
    }
  }

  func replaceCurrencyAt(position: Int, currency: Currency) async {
    await withContext { context in
      await context.fetchAll(FetchDescriptor<FavoriteCurrenciesSwiftDataModel>())
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
