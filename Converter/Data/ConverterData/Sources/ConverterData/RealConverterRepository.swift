import CommonUtils
import ConverterStorage
import ConverterDomain
import CurrencyDomain

final class RealConverterRepository: ConverterRepository {
  
  private let converterStorage: ConverterStorage
  
  init(converterStorage: ConverterStorage) {
    self.converterStorage = converterStorage
  }
  
  func getFavoriteCurrencies() async -> Result<FavoriteCurrencies, DataError> {
    let result = await converterStorage.fetchFavoriteCurrencies()
      .print { "Get favorite currencies from Storage: \($0)" }
    return await result
      .map { storageModel in storageModel.toDomainModel() }
      .recover(.success(.initial))
  }
  
  func setCurrencyAt(position: Int, currency: Currency) async {
    await converterStorage.replaceCurrencyAt(position: position, currency: currency)
  }
}
