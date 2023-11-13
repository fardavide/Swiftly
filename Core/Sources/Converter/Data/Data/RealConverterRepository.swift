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
      .print { "Get favorite currencies from Storage: \($0)" }
    return await result
      .map { storageModel in storageModel.toDomainModel() }
      .recover(.success(.initial))
  }

  func setCurrencyAt(position: Int, currency: Currency) async {
    await currencyStorage.insertCurrencySelected(code: currency.code)
    await converterStorage.replaceCurrencyAt(position: position, currency: currency)
  }
}
