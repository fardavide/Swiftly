import ConverterStorage
import ConverterDomain
import CurrencyDomain
import CurrencyStorage
import SwiftlyUtils

final class RealConverterRepository: ConverterRepository {

  private let converterStorage: ConverterStorage
  private let currencyStorage: CurrencyStorage

  init(
    converterStorage: ConverterStorage,
    currencyStorage: CurrencyStorage
  ) {
    self.converterStorage = converterStorage
    self.currencyStorage = currencyStorage
  }

  func getSelectedCurrencies() async -> Result<SelectedCurrencies, DataError> {
    let result = await converterStorage.fetchSelectedCurrencies()
      .print { "Get selected currencies from Storage: \($0)" }
    return await result
      .map { storageModel in storageModel.toDomainModel() }
      .recover(.success(.initial))
  }
  
  func setSelectedCurrencies(_ selectedCurrencies: [CurrencyCode]) async {
    var codes: [SelectedCurrencyPosition: CurrencyCode] = [:]
    for (index, code) in selectedCurrencies.withIndices() {
      codes[SelectedCurrencyPosition(value: index)] = code
    }
    let model = SelectedCurrenciesStorageModel(currencyCodes: codes)
    await converterStorage.insertSelectedCurrencies(model)
  }
}
