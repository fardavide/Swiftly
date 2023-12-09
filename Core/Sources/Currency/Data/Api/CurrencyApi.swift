import CurrencyDomain
import Foundation
import Network

public protocol CurrencyApi {

  func currencies() async -> Result<CurrenciesApiModel, ApiError>

  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError>
}

public class FakeCurrencyApi: CurrencyApi {
  
  public private(set) var didFetchCurrencies = false
  public private(set) var didFetchLatestRates = false

  private let currenciesResult: Result<any CurrenciesApiModel, ApiError>
  private let latestRatesResult: Result<CurrencyRatesApiModel, ApiError>

  public init(
    currenciesResult: Result<any CurrenciesApiModel, ApiError> = .failure(.unknown),
    latestRatesResult: Result<CurrencyRatesApiModel, ApiError> = .failure(.unknown)
  ) {
    self.currenciesResult = currenciesResult
    self.latestRatesResult = latestRatesResult
  }

  public func currencies() async -> Result<any CurrenciesApiModel, ApiError> {
    didFetchCurrencies = true
    return currenciesResult
  }

  public func latestRates() async -> Result<CurrencyRatesApiModel, ApiError> {
    didFetchLatestRates = true
    return latestRatesResult
  }
}
