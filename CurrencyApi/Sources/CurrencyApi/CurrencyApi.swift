//
//  CurrencyApi.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//
import CommonNetwork
import Foundation

public protocol CurrencyApi {
  
  func latestRates() async -> Result<CurrencyRatesApiModel, ApiError>
}

final class RealCurrencyApi: CurrencyApi {
    
  public func latestRates() async -> Result<CurrencyRatesApiModel, ApiError> {
    await URLSession.shared.resultData(
      from: Endpoint.latestRates().url
    )
  }
}

public class FakeCurrencyApi: CurrencyApi {
  public private(set) var didFetch = false
  private let latestResult: Result<CurrencyRatesApiModel, ApiError>
  
  public init(
    latestResult: Result<CurrencyRatesApiModel, ApiError> = .failure(.unknown)
  ) {
    self.latestResult = latestResult
  }
  
  public func latestRates() -> Result<CurrencyRatesApiModel, ApiError> {
    didFetch = true
    return latestResult
  }
}
