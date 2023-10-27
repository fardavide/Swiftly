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
  
  func latest() async -> Result<CurrencyRatesDto, ApiError>
}

final class RealCurrencyApi: CurrencyApi {
  
  public func latest() async -> Result<CurrencyRatesDto, ApiError> {
    let url = URL(string: "\(baseUrl)latest?apikey=\(apiKey)")!
    return await URLSession.shared.resultData(from: url)
  }
}

public class FakeCurrencyApi: CurrencyApi {
  
  public func latest() -> Result<CurrencyRatesDto, ApiError> {
    .success(CurrencyRatesDto.sample)
  }
}
