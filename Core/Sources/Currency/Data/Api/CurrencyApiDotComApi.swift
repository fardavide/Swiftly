import Foundation
import Network

final class CurrencyApiDotComApi: CurrencyApi {
  
  private let endpoints: Endpoints
  
  init(endpoints: Endpoints) {
    self.endpoints = endpoints
  }
  
  func currencies() async -> Result<CurrenciesApiModel, Network.ApiError> {
    await _currencies().map { $0 }
  }
  
  /// see: https://currencyapi.com/docs/currencies
  private func _currencies() async -> Result<CurrenciesCurrencyApiDotComModel, ApiError> {
    await URLSession.shared.resultData(
      from: endpoints.currencies()
    )
  }
  
  /// see: https://currencyapi.com/docs/latest
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError> {
    await URLSession.shared.resultData(
      from: endpoints.lastRates()
    )
  }
}
