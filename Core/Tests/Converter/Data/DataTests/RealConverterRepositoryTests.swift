import XCTest

import ConverterDomain
import ConverterStorage
import CurrencyDomain
import CurrencyStorage
import PowerAssert
import SwiftlyStorage
@testable import ConverterData

final class RealConverterRepositoryTests: XCTestCase {
  
  func test_setCurrency_insertsCurrencySelected() async {
    // given
    let scenario = Scenario()
    
    // when
    await scenario.sut.setCurrencyAt(position: 0, currency: .samples.eur)
    
    // then
    #assert(scenario.currencyStorage.selectedCurrencies[CurrencyCode.samples.eur] == 1)
  }
  
  func test_whenNoSelectedCurrencies_defaultAreReturned() async {
    // given
    let scenario = Scenario(
      selectedCurrencies: SelectedCurrenciesStorageModel(currencyCodes: [:])
    )
    
    // when
    let result = await scenario.sut.getSelectedCurrencies()
    
    // then
    #assert(result == .success(.initial))
  }
  
  func test_whenOneSelectedCurrency_defaultIsReplaced() async {
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
    #assert(result.orThrow().currencyCodes == expected)
  }
  
  func test_whenOneInitialCurrencyIsSelectedInAnotherPosition_itIsNotDuplicated() async {
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
    #assert(result.orThrow().currencyCodes == expected)
  }
  
  func test_whenThreeCurrenciesAreSelected_ThreeCurrenciesAreRetruned() async {
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
    #assert(result.orThrow().currencyCodes == expected)
  }
  
  func test_moreCurrenciesThanMaxAreSelected_maxIsRetuned() async {
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
    #assert(selectedCodes.count > SelectedCurrencies.maxItems)
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
    #assert(result.orThrow().currencyCodes == expected)
  }
}

private final class Scenario {
  
  let currencyStorage: FakeCurrencyStorage
  let sut: RealConverterRepository
  
  init(
    converterStorage: ConverterStorage = FakeConverterStorage(),
    currencyStorage: FakeCurrencyStorage = FakeCurrencyStorage()
  ) {
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
