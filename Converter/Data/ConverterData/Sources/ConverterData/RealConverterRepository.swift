import CommonUtils
import ConverterStorage
import ConverterDomain

final class RealConverterRepository: ConverterRepository {
  
  private let converterStorage: ConverterStorage
  
  init(converterStorage: ConverterStorage) {
    self.converterStorage = converterStorage
  }
  
  func getFavoriteCurrencies() async -> Result<FavoriteCurrencies, DataError> {
    let result = await converterStorage.fetchFavoriteCurrencies()
    return await result
      .map { storageModel in storageModel.toDomainModel() }
      .recover(.success(.initial))
  }
}
