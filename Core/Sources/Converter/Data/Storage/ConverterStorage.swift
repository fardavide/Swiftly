import AppStorage
import ConverterDomain
import CurrencyDomain
import Foundation
import SwiftData
import SwiftlyStorage

public protocol ConverterStorage {

  func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError>

  func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async

  func removeCurrencyAt(position: Int) async
  
  func replaceCurrencyAt(position: Int, currency: Currency) async
}

public final class FakeConverterStorage: ConverterStorage {
  
  private let selectedCurrenciesResult: Result<SelectedCurrenciesStorageModel, StorageError>
  
  public init(
    selectedCurrenciesResult: Result<SelectedCurrenciesStorageModel, StorageError> = .failure(.unknown)
  ) {
    self.selectedCurrenciesResult = selectedCurrenciesResult
  }
  
  public convenience init(
    selectedCurrencies: SelectedCurrenciesStorageModel
  ) {
    self.init(selectedCurrenciesResult: .success(selectedCurrencies))
  }
  
  public func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError> {
    selectedCurrenciesResult
  }
  
  public func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async {}
  
  public func removeCurrencyAt(position: Int) async {}
  
  public func replaceCurrencyAt(position: Int, currency: CurrencyDomain.Currency) async {}
}

class RealConverterStorage: AppStorage, ConverterStorage {

  let container: ModelContainer

  init(container: ModelContainer) {
    self.container = container
  }

  func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError> {
    await withContext {
      $0.fetchAll(FetchDescriptor<SelectedCurrenciesSwiftDataModel>()).flatMap { models in
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
  
  func removeCurrencyAt(position: Int) async {
    await withContext { context in
      let result = context.fetchOne(FetchDescriptor<SelectedCurrenciesSwiftDataModel>())
      await result.onSuccess { model in
        model.currencyCodes.removeValue(forKey: SelectedCurrencyPosition(value: position))
      }
    }
  }

  func replaceCurrencyAt(position: Int, currency: Currency) async {
    await withContext { context in
      await context.fetchAll(FetchDescriptor<SelectedCurrenciesSwiftDataModel>())
        .flatMap { value in !value.isEmpty ? .success(value.first!) : .failure(.noCache) }
        .onSuccess { model in
          model.replaceAt(position: position, newValue: currency.code)
        }
        .onFailure { _ in
          context.insert(
            SelectedCurrenciesSwiftDataModel(
              currencyCodes: [SelectedCurrencyPosition(value: position): currency.code]
            )
          )
        }
    }
  }
}
