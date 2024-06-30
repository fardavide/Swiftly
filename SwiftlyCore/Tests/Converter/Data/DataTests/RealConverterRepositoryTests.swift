import Testing

import ConverterDomain
import ConverterStorage
import CurrencyDomain
import CurrencyStorage
import SwiftlyStorage
@testable import ConverterData

struct RealConverterRepositoryTests {
  
  @Test
  func setSelectedCurrencies_insertsCurrencies() async {
    // given
    let scenario = Scenario()
    
    // when
    await scenario.sut.setSelectedCurrencies(
      [
        .samples.eur,
        .samples.jpy,
        .samples.cny
      ]
    )
    
    // then
    let expected = [
      SelectedCurrencyPosition(value: 0): CurrencyCode.samples.eur,
      SelectedCurrencyPosition(value: 1): CurrencyCode.samples.jpy,
      SelectedCurrencyPosition(value: 2): CurrencyCode.samples.cny
    ]
    #expect(scenario.converterStorage.selectedCurrencies == expected)
  }
  
  @Test
  func whenNoSelectedCurrencies_defaultAreReturned() async {
    // given
    let scenario = Scenario(
      selectedCurrencies: SelectedCurrenciesStorageModel(currencyCodes: [:])
    )
    
    // when
    let result = await scenario.sut.getSelectedCurrencies()
    
    // then
    #expect(result == .success(.initial))
  }
  
  @Test
  func whenOneSelectedCurrency_defaultIsReplaced() async {
    // given
    let scenario = Scenario(
      selectedCurrencies: SelectedCurrenciesStorageModel(
        currencyCodes: [
          SelectedCurrencyPosition(value: 1): .samples.cny
        ]
      )
    )
    
    // when
    let result = await scenario.sut.getSelectedCurrencies()
    
    // then
    let expected = [
      SelectedCurrencies.initial.currencyCodes[0],
      .samples.cny
    ]
    #expect(result.orThrow().currencyCodes == expected)
  }
  
  @Test
  func whenOneInitialCurrencyIsSelectedInAnotherPosition_itIsNotDuplicated() async {
    // given
    let scenario = Scenario(
      selectedCurrencies: SelectedCurrenciesStorageModel(
        currencyCodes: [
          SelectedCurrencyPosition(value: 1): .samples.eur
        ]
      )
    )
    
    // when
    let result = await scenario.sut.getSelectedCurrencies()
    
    // then
    let expected = [
      CurrencyCode.samples.usd,
      CurrencyCode.samples.eur
    ]
    #expect(result.orThrow().currencyCodes == expected)
  }
  
  @Test
  func whenThreeCurrenciesAreSelected_ThreeCurrenciesAreRetruned() async {
    // given
    let scenario = Scenario(
      selectedCurrencies: SelectedCurrenciesStorageModel(
        currencyCodes: [
          SelectedCurrencyPosition(value: 0): .samples.gbp,
          SelectedCurrencyPosition(value: 1): .samples.cny,
          SelectedCurrencyPosition(value: 2): .samples.jpy
        ]
      )
    )
    
    // when
    let result = await scenario.sut.getSelectedCurrencies()
    
    // then
    let expected = [
      CurrencyCode.samples.gbp,
      CurrencyCode.samples.cny,
      CurrencyCode.samples.jpy
    ]
    #expect(result.orThrow().currencyCodes == expected)
  }
  
  @Test
  func whenMoreCurrenciesThanMaxAreSelected_maxIsRetuned() async {
    // given
    let selectedCodes = [
      SelectedCurrencyPosition(value: 0): CurrencyCode.samples.aud,
      SelectedCurrencyPosition(value: 1): CurrencyCode.samples.chf,
      SelectedCurrencyPosition(value: 2): CurrencyCode.samples.cny,
      SelectedCurrencyPosition(value: 3): CurrencyCode.samples.eur,
      SelectedCurrencyPosition(value: 4): CurrencyCode.samples.gbp,
      SelectedCurrencyPosition(value: 5): CurrencyCode.samples.jpy,
      SelectedCurrencyPosition(value: 6): CurrencyCode.samples.usd
    ]
    #expect(selectedCodes.count > SelectedCurrencies.maxItems)
    let scenario = Scenario(
      selectedCurrencies: SelectedCurrenciesStorageModel(
        currencyCodes: selectedCodes
      )
    )
    
    // when
    let result = await scenario.sut.getSelectedCurrencies()
    
    // then
    let expected = [
      CurrencyCode.samples.aud,
      CurrencyCode.samples.chf,
      CurrencyCode.samples.cny,
      CurrencyCode.samples.eur,
      CurrencyCode.samples.gbp,
      CurrencyCode.samples.jpy
    ]
    #expect(result.orThrow().currencyCodes == expected)
  }
}

private final class Scenario {
  
  let converterStorage: FakeConverterStorage
  let currencyStorage: FakeCurrencyStorage
  let sut: RealConverterRepository
  
  init(
    converterStorage: FakeConverterStorage = FakeConverterStorage(),
    currencyStorage: FakeCurrencyStorage = FakeCurrencyStorage()
  ) {
    self.converterStorage = converterStorage
    self.currencyStorage = currencyStorage
    self.sut = RealConverterRepository(
      converterStorage: converterStorage,
      currencyStorage: currencyStorage
    )
  }
  
  convenience init(
    selectedCurrenciesResult: Result<SelectedCurrenciesStorageModel, StorageError> = .failure(.unknown)
  ) {
    self.init(
      converterStorage: FakeConverterStorage(
        selectedCurrenciesResult: selectedCurrenciesResult
      ),
      currencyStorage: FakeCurrencyStorage()
    )
  }
  
  convenience init(
    selectedCurrencies: SelectedCurrenciesStorageModel
  ) {
    self.init(selectedCurrenciesResult: .success(selectedCurrencies))
  }
}
