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
    return result
      .map { storageModel in storageModel.toDomainModel() }
      .mapError { $0.toDataError() }
  }
}
