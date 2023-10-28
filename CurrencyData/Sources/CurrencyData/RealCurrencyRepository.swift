//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonNetwork
import CommonUtils
import CurrencyApi
import CurrencyDomain

public final class RealCurrencyRepository: CurrencyRepository {
  
  let api: CurrencyApi
  
  init(api: CurrencyApi) {
    self.api = api
  }
  
  public func getLatestRates() async -> Result<[CurrencyRate], DataError> {
    let ratesDtoResult = await api.latest()
    switch ratesDtoResult {
      
    case let .success(currencyRatesDto):
      return .success(currencyRatesDto.toDomainModels())
      
    case let .failure(apiError):
      switch apiError {
        
      case .unknown:
        return .failure(.network)
        
      case .jsonError:
        return .failure(.network)
      }
    }
  }
}

private extension CurrencyRatesDto {
  func toDomainModels() -> [CurrencyRate] {
    self.data
      .filter { code, _ in Currency.from(code: code) != nil }
      .map { code, currencyDto in
        let currency = Currency.from(code: code)!
        return CurrencyRate(currency: currency, rate: currencyDto.value)
      }
  }
}
