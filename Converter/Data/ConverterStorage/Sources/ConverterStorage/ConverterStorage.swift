import CommonStorage
import SwiftData

public protocol ConverterStorage {
  
  func insertFavoriteCurrencies(_ model: FavoriteCurrenciesStorageModel) async
  
  func fetchFavoriteCurrencies() async -> Result<FavoriteCurrenciesStorageModel, StorageError>
}

class RealConverterStorage : ConverterStorage {
  private let configuration = ModelConfiguration()
  
  private var container: ModelContainer {
    do {
      return try ModelContainer(
        for: FavoriteCurrenciesSwiftDataModel.self,
        configurations: configuration
      )
    } catch {
      fatalError(error.localizedDescription)
    }
  }
  
  func insertFavoriteCurrencies(_ model: FavoriteCurrenciesStorageModel) async {
    await withContext {
      $0.insert(model.toSwiftDataModel())
    }
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
  
  private func withContext<T>(_ f: (ModelContext) -> T) async -> T {
    let context = await container.mainContext
    return f(context)
  }
}
