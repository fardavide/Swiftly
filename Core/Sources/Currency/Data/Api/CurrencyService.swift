import Foundation
import Network

protocol CurrencyService {
  
  func currencies() async -> Result<CurrenciesApiModel, ApiError>
}

final class CurrencyApiComCurrencyService: CurrencyService {
  private let endpoints: CurrencyApiComEndpoints
  
  init(endpoints: CurrencyApiComEndpoints) {
    self.endpoints = endpoints
  }
  
  func currencies() async -> Result<CurrenciesApiModel, ApiError> {
    await _currencies().map { $0 }
  }
  
  /// see: https://currencyapi.com/docs/currencies
  private func _currencies() async -> Result<CurrenciesCurrencyApiComModel, ApiError> {
    await URLSession.shared.resultData(
      from: endpoints.currencies()
    )
  }
}

final class CurrencyBeaconComCurrencyService: CurrencyService {
  private let endpoints: CurrencyBeaconComEndpoints
  
  init(endpoints: CurrencyBeaconComEndpoints) {
    self.endpoints = endpoints
  }
  
  func currencies() async -> Result<CurrenciesApiModel, ApiError> {
    await _currencies().map { $0 }
  }
  
  /// see: https://currencybeacon.com/api-documentation
  private func _currencies() async -> Result<CurrenciesCurrencyBeaconComModel, ApiError> {
    await URLSession.shared.resultData(
      from: endpoints.currencies()
    )
  }
}
