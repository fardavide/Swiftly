import AppStorage
import ConverterDomain
import CurrencyDomain
import Foundation
import SwiftData
import SwiftlyStorage

public protocol ConverterStorage {

  func fetchSelectedCurrencies() async -> Result<SelectedCurrenciesStorageModel, StorageError>

  func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async
}

public final class FakeConverterStorage: ConverterStorage {
  
  public var selectedCurrencies = [SelectedCurrencyPosition: CurrencyCode]()
  
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
  
  public func insertSelectedCurrencies(_ model: SelectedCurrenciesStorageModel) async {
    selectedCurrencies = model.currencyCodes
  }
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
}
