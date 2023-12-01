import XCTest

import ConverterDomain
@testable import ConverterStorage

final class SelectedCurrenciesStorageModelTests: XCTestCase {

  func test_whenConvertToDomainModel_selectedAreSortedCorrectly() {
    // given
    let storageModel = SelectedCurrenciesStorageModel(
      currencyCodes: [
        SelectedCurrencyPosition(value: 1): .samples.usd,
        SelectedCurrencyPosition(value: 3): .samples.cny,
        SelectedCurrencyPosition(value: 5): .samples.gbp,
        SelectedCurrencyPosition(value: 4): .samples.chf,
        SelectedCurrencyPosition(value: 2): .samples.jpy,
        SelectedCurrencyPosition(value: 0): .samples.eur
      ]
    )

    // when
    let domainModel = storageModel.toDomainModel()

    // then
    XCTAssertEqual(
      domainModel,
      SelectedCurrencies.of(
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
    let storageModel = SelectedCurrenciesStorageModel(
      currencyCodes: [
        SelectedCurrencyPosition(value: 0): .samples.eur,
        SelectedCurrencyPosition(value: 2): .samples.jpy,
        SelectedCurrencyPosition(value: 4): .samples.chf
      ]
    )

    // when
    let domainModel = storageModel.toDomainModel()

    // then
    XCTAssertEqual(
      domainModel,
      SelectedCurrencies.of(
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