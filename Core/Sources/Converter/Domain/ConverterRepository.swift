import CurrencyDomain
import SwiftlyUtils

public protocol ConverterRepository {

  func getSelectedCurrencies() async -> Result<SelectedCurrencies, DataError>
  func setSelectedCurrencies(_ selectedCurrencies: [CurrencyCode]) async
}

public final class FakeConverterRepository: ConverterRepository {
  
  private let selectedCurrenciesResult: Result<SelectedCurrencies, DataError>

  public init(
    selectedCurrenciesResult: Result<SelectedCurrencies, DataError> = .failure(.unknown)
  ) {
    self.selectedCurrenciesResult = selectedCurrenciesResult
  }

  public convenience init(
    selectedCurrencies: SelectedCurrencies
  ) {
    self.init(
      selectedCurrenciesResult: .success(selectedCurrencies)
    )
  }

  public func getSelectedCurrencies() async -> Result<SelectedCurrencies, DataError> {
    selectedCurrenciesResult
  }
  public func setSelectedCurrencies(_ selectedCurrencies: [CurrencyCode]) async {}
}
