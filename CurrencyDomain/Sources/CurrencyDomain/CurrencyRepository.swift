//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonUtils
import Foundation

public protocol CurrencyRepository {
  
  func getCurrencies() async -> Result<[Currency], DataError>
  func getLatestRates() async -> Result<[CurrencyRate], DataError>
}

public class FakeCurrencyRepository: CurrencyRepository {
  let currenciesResult: Result<[Currency], DataError>
  let currencyRatesResult: Result<[CurrencyRate], DataError>
  
  public init(
    currenciesResult: Result<[Currency], DataError> = .failure(.unknown),
    currencyRatesResult: Result<[CurrencyRate], DataError> = .failure(.unknown)
  ) {
    self.currenciesResult = currenciesResult
    self.currencyRatesResult = currencyRatesResult
  }
  
  public convenience init(
    currencies: [Currency]? = nil,
    currencyRates: [CurrencyRate]? = nil
  ) {
    self.init(
      currenciesResult: currencies != nil ? .success(currencies!) : .failure(.unknown),
      currencyRatesResult: currencyRates != nil ? .success(currencyRates!) : .failure(.unknown)
    )
  }
  
  public func getCurrencies() async -> Result<[Currency], DataError> {
    currenciesResult
  }
  public func getLatestRates() async -> Result<[CurrencyRate], DataError> {
    currencyRatesResult
  }
}
