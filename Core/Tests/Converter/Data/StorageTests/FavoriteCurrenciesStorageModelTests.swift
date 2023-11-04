import XCTest

import ConverterDomain
@testable import ConverterStorage

final class FavoriteCurrenciesStorageModelTests: XCTestCase {
  
  func test_whenConvertToDomainModel_favoritesAreSortedCorrectly() {
    // given
    let storageModel = FavoriteCurrenciesStorageModel(
      currencyCodes: [
        FavoriteCurrencyPosition(value: 1): .samples.usd,
        FavoriteCurrencyPosition(value: 3): .samples.cny,
        FavoriteCurrencyPosition(value: 5): .samples.gbp,
        FavoriteCurrencyPosition(value: 4): .samples.chf,
        FavoriteCurrencyPosition(value: 2): .samples.jpy,
        FavoriteCurrencyPosition(value: 0): .samples.eur
      ]
    )
    
    // when
    let domainModel = storageModel.toDomainModel()
    
    // then
    XCTAssertEqual(
      domainModel,
      FavoriteCurrencies.of(
        currencyCodes: [
          .samples.eur,
          .samples.usd,
          .samples.jpy,
          .samples.cny,
          .samples.chf,
          .samples.gbp
        ]
      )
    )
  }
  
  func test_whenConvertToDomainModel_andNotEnoughValues_gapsAreFilledWithDefaults() {
    // given
    let storageModel = FavoriteCurrenciesStorageModel(
      currencyCodes: [
        FavoriteCurrencyPosition(value: 0): .samples.eur,
        FavoriteCurrencyPosition(value: 2): .samples.jpy,
        FavoriteCurrencyPosition(value: 4): .samples.chf
      ]
    )
    
    // when
    let domainModel = storageModel.toDomainModel()
    
    // then
    XCTAssertEqual(
      domainModel,
      FavoriteCurrencies.of(
        currencyCodes: [
          .samples.eur,
          .samples.usd,
          .samples.jpy,
          .samples.gbp,
          .samples.chf,
          .samples.cny
        ]
      )
    )
  }
}
