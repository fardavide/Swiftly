import Foundation
import Network

public protocol CurrencyApi {
  
  /// see: https://currencyapi.com/docs/currencies
  func currencies() async -> Result<CurrenciesApiModel, ApiError>
  
  /// see: https://currencyapi.com/docs/latest
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError>
}

final class RealCurrencyApi: CurrencyApi {
  
  func currencies() async -> Result<CurrenciesApiModel, ApiError> {
    await URLSession.shared.resultData(
      from: Endpoint.currencties().url
    )
  }
  
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError> {
    await URLSession.shared.resultData(
      from: Endpoint.latestRates().url
    )
  }
}

public class FakeCurrencyApi: CurrencyApi {
  
  public private(set) var didFetchCurrencies = false
  public private(set) var didFetchLatestRates = false
  
  private let currenciesResult: Result<CurrenciesApiModel, ApiError>
  private let latestRatesResult: Result<CurrencyRatesApiModel, ApiError>
  
  public init(
    currenciesResult: Result<CurrenciesApiModel, ApiError> = .failure(.unknown),
    latestRatesResult: Result<CurrencyRatesApiModel, ApiError> = .failure(.unknown)
  ) {
    self.currenciesResult = currenciesResult
    self.latestRatesResult = latestRatesResult
  }
  
  public func currencies() async -> Result<CurrenciesApiModel, ApiError> {
    didFetchCurrencies = true
    return currenciesResult
  }
  
  public func latestRates() -> Result<CurrencyRatesApiModel, ApiError> {
    didFetchLatestRates = true
    return latestRatesResult
  }
}
