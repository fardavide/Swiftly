//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonUtils
import Foundation

public protocol CurrencyRepository {
  
  func getLatestRates() async -> Result<[CurrencyRate], DataError>
}

public class FakeCurrencyRepository: CurrencyRepository {
  let result: Result<[CurrencyRate], DataError>
  
  public init(
    result: Result<[CurrencyRate], DataError> = .failure(.unknown)
  ) {
    self.result = result
  }
  
  public convenience init(currencyRates: [CurrencyRate]) {
    self.init(result: .success(currencyRates))
  }
  
  public func getLatestRates() async -> Result<[CurrencyRate], DataError> {
    result
  }
}
