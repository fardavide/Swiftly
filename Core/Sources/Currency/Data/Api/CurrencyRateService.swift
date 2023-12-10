import Foundation
import Network

protocol CurrencyRateService {
  
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError>
}

final class CurrencyApiComCurrencyRateService: CurrencyRateService {
  
  private let endpoints: CurrencyApiComEndpoints
  
  init(endpoints: CurrencyApiComEndpoints) {
    self.endpoints = endpoints
  }
  
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError> {
    await _latestRates().map { $0 }
  }
  
  /// see: https://currencyapi.com/docs/latest
  private func _latestRates() async -> Result<CurrencyRatesCurrencyApiComModel, ApiError> {
    await URLSession.shared.resultData(
      from: endpoints.lastRates()
    )
  }
}

final class ExchangeRatesIoCurrencyRateService: CurrencyRateService {
  
  private let endpoints: ExchangeRatesIoEndpoints
  
  init(endpoints: ExchangeRatesIoEndpoints) {
    self.endpoints = endpoints
  }
  
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError> {
    await _latestRates().map { $0 }
  }
  
  /// see: https://exchangeratesapi.io/documentation/#latestrates
  private func _latestRates() async -> Result<CurrencyRatesExchangeRatesIoModel, ApiError> {
    await URLSession.shared.resultData(
      from: endpoints.lastRates()
    )
  }
}
