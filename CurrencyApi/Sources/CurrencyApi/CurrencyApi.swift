//
//  CurrencyApi.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//
import CommonNetwork
import Foundation

private let baseUrl = "https://api.currencyapi.com/v3/"

public protocol CurrencyApi {
  
  func latest() async -> Result<CurrencyRatesApiModel, ApiError>
}

final class RealCurrencyApi: CurrencyApi {
  
  public func latest() async -> Result<CurrencyRatesApiModel, ApiError> {
    let url = URL(string: "\(baseUrl)latest?apikey=\(apiKey)")!
    return await URLSession.shared.resultData(from: url)
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
  
  public func latest() -> Result<CurrencyRatesApiModel, ApiError> {
    didFetch = true
    return latestResult
  }
}
