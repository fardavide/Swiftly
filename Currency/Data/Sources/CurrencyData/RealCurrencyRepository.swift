//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonUtils
import CurrencyApi
import CurrencyDomain

public final class RealCurrencyRepository: CurrencyRepository {
  
  let api: CurrencyApi
  
  init(api: CurrencyApi) {
    self.api = api
  }
  
  public func getLatestRates() async -> Result<[CurrencyWeight], DataError> {
    // TODO: impl
    .failure(.network)
  }
}
