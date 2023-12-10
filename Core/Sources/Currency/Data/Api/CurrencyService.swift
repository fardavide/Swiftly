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
