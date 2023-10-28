//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonUtils
import Foundation

public protocol CurrencyRepository {
  
  func getLatestRates() async -> Result<[CurrencyWeight], DataError>
}

public class FakeCurrencyRepository: CurrencyRepository {
  let result: Result<[CurrencyWeight], DataError>
  
  public init(
    result: Result<[CurrencyWeight], DataError> = .failure(.unknown)
  ) {
    self.result = result
  }
  
  public func getLatestRates() async -> Result<[CurrencyWeight], DataError> {
    result
  }
}
