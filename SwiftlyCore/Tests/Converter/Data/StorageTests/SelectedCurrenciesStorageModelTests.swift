import Testing

import ConverterDomain
@testable import ConverterStorage

struct SelectedCurrenciesStorageModelTests {

  @Test
  func whenConvertToDomainModel_selectedAreSortedCorrectly() {
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
    let expected = SelectedCurrencies.of(
      currencyCodes: [
        .samples.eur,
        .samples.usd,
        .samples.jpy,
        .samples.cny,
        .samples.chf,
        .samples.gbp
      ]
    )
    #expect(domainModel == expected)
  }

  @Test
  func whenConvertToDomainModel_gapsAreIgnored() {
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
    let expected = SelectedCurrencies.of(
      currencyCodes: [
        .samples.eur,
        .samples.jpy,
        .samples.chf
      ]
    )
    #expect(domainModel == expected)
  }

  @Test
  func whenConvertToDomainModel_positionOutOfRange_gapsAreIgnored() {
    // given
    let storageModel = SelectedCurrenciesStorageModel(
      currencyCodes: [
        SelectedCurrencyPosition(value: 4): .samples.chf
      ]
    )

    // when
    let domainModel = storageModel.toDomainModel()

    // then
    let expected = SelectedCurrencies.of(
      currencyCodes: [
        .samples.chf
      ]
    )
    #expect(domainModel == expected)
  }
}
