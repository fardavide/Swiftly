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
import CurrencyStorage

public final class RealCurrencyRepository: CurrencyRepository {
  
  let api: CurrencyApi
  let storage: CurrencyStorage
  
  init(
    api: CurrencyApi,
    storage: CurrencyStorage
  ) {
    self.api = api
    self.storage = storage
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
