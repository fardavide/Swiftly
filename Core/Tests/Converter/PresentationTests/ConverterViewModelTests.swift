// swiftlint:disable function_body_length
import XCTest

import Combine
import ConverterDomain
import CurrencyDomain
import PowerAssert
import SwiftlyTest
@testable import ConverterPresentation

final class ConverterViewModelTests: XCTestCase {
  
  func test_loadAllCurrencies() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all,
      selectedCurrencies: .samples.alphabetical
    )
    
    // when
    await test(scenario.sut.$state.map(\.searchCurrencies)) { turbine in
      await turbine.expectInitial(value: [])
      
      // then
      let result = await turbine.value()
      #assert(result == Currency.samples.all())
    }
  }
  
  func test_loadCurrencyValues() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all,
      selectedCurrencies: .samples.alphabetical
    )
    
    // when
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      // then
      let result = await turbine.value()
      #assert(result.count == 6)
      
      #assert(result[0].currency == Currency.samples.chf)
      #assert(result[0].rate == CurrencyRate.samples.chf.rate)
      #assert(result[0].value == 10)
      
      #assert(result[1].currency == Currency.samples.cny)
      #assert(result[1].rate == CurrencyRate.samples.cny.rate)
      #assert(result[1] ~= 81)
      
      #assert(result[2].currency == Currency.samples.eur)
      #assert(result[2].rate == CurrencyRate.samples.eur.rate)
      #assert(result[2] ~= 10)
      
      #assert(result[3].currency == Currency.samples.gbp)
      #assert(result[3].rate == CurrencyRate.samples.gbp.rate)
      #assert(result[3] ~= 9)
      
      #assert(result[4].currency == Currency.samples.jpy)
      #assert(result[4].rate == CurrencyRate.samples.jpy.rate)
      #assert(result[4] ~= 1667)
      
      #assert(result[5].currency == Currency.samples.usd)
      #assert(result[5].rate == CurrencyRate.samples.usd.rate)
      #assert(result[5] ~= 11)
    }
  }
  
  func test_whenValueUpdate_ratesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all,
      selectedCurrencies: .samples.alphabetical
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      #assert(before.count == 6)
      
      #assert(before[0].currency == Currency.samples.chf)
      #assert(before[0].rate == CurrencyRate.samples.chf.rate)
      #assert(before[0].value == 10)
      
      #assert(before[1].currency == Currency.samples.cny)
      #assert(before[1].rate == CurrencyRate.samples.cny.rate)
      #assert(before[1] ~= 81)
      
      #assert(before[2].currency == Currency.samples.eur)
      #assert(before[2].rate == CurrencyRate.samples.eur.rate)
      #assert(before[2] ~= 10)
      
      #assert(before[3].currency == Currency.samples.gbp)
      #assert(before[3].rate == CurrencyRate.samples.gbp.rate)
      #assert(before[3] ~= 9)
      
      #assert(before[4].currency == Currency.samples.jpy)
      #assert(before[4].rate == CurrencyRate.samples.jpy.rate)
      #assert(before[4] ~= 1667)
      
      #assert(before[5].currency == Currency.samples.usd)
      #assert(before[5].rate == CurrencyRate.samples.usd.rate)
      #assert(before[5] ~= 11)
      
      // when
      scenario.sut.send(
        .updateValue(
          currencyValue: CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.usd)
        )
      )
      
      // then
      let after = await turbine.value()
      #assert(after.count == 6)
      
      #assert(after[0].currency == Currency.samples.chf)
      #assert(after[0].rate == CurrencyRate.samples.chf.rate)
      #assert(after[0] ~= 18)
      
      #assert(after[1].currency == Currency.samples.cny)
      #assert(after[1].rate == CurrencyRate.samples.cny.rate)
      #assert(after[1] ~= 146)
      
      #assert(after[2].currency == Currency.samples.eur)
      #assert(after[2].rate == CurrencyRate.samples.eur.rate)
      #assert(after[2] ~= 18)
      
      #assert(after[3].currency == Currency.samples.gbp)
      #assert(after[3].rate == CurrencyRate.samples.gbp.rate)
      #assert(after[3] ~= 16)
      
      #assert(after[4].currency == Currency.samples.jpy)
      #assert(after[4].rate == CurrencyRate.samples.jpy.rate)
      #assert(after[4] ~= 3000)
      
      #assert(after[5].currency == Currency.samples.usd)
      #assert(after[5].rate == CurrencyRate.samples.usd.rate)
      #assert(after[5].value == 20)
    }
  }
  
  func test_whenCurrencyChange_otherRatesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all,
      selectedCurrencies: .samples.alphabetical
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      #assert(before.count == 6)
      
      #assert(before[0].currency == Currency.samples.chf)
      #assert(before[0].rate == CurrencyRate.samples.chf.rate)
      #assert(before[0].value == 10)
      
      #assert(before[1].currency == Currency.samples.cny)
      #assert(before[1].rate == CurrencyRate.samples.cny.rate)
      #assert(before[1] ~= 81)
      
      #assert(before[2].currency == Currency.samples.eur)
      #assert(before[2].rate == CurrencyRate.samples.eur.rate)
      #assert(before[2] ~= 10)
      
      #assert(before[3].currency == Currency.samples.gbp)
      #assert(before[3].rate == CurrencyRate.samples.gbp.rate)
      #assert(before[3] ~= 9)
      
      #assert(before[4].currency == Currency.samples.jpy)
      #assert(before[4].rate == CurrencyRate.samples.jpy.rate)
      #assert(before[4] ~= 1667)
      
      #assert(before[5].currency == Currency.samples.usd)
      #assert(before[5].rate == CurrencyRate.samples.usd.rate)
      #assert(before[5] ~= 11)
      
      // when
      scenario.sut.send(
        .changeCurrency(
          prev: Currency.samples.eur,
          new: Currency.samples.cny
        )
      )
      
      // then
      let after = await turbine.value()
      #assert(after.count == 6)
      
      #assert(after[0].currency == Currency.samples.chf)
      #assert(after[0].rate == CurrencyRate.samples.chf.rate)
      #assert(after[0] ~= 1)
      
      #assert(after[1].currency == Currency.samples.eur)
      #assert(after[1].rate == CurrencyRate.samples.eur.rate)
      #assert(after[1] ~= 1.2)
      
      #assert(after[2].currency == Currency.samples.cny)
      #assert(after[2].rate == CurrencyRate.samples.cny.rate)
      #assert(after[2].value == 10)
      
      #assert(after[3].currency == Currency.samples.gbp)
      #assert(after[3].rate == CurrencyRate.samples.gbp.rate)
      #assert(after[3] ~= 1)
      
      #assert(after[4].currency == Currency.samples.jpy)
      #assert(after[4].rate == CurrencyRate.samples.jpy.rate)
      #assert(after[4] ~= 205)
      
      #assert(after[5].currency == Currency.samples.usd)
      #assert(after[5].rate == CurrencyRate.samples.usd.rate)
      #assert(after[5] ~= 1)
    }
  }
  
  func test_whenSearch_currenciesAreFiltered() async {
    // given
    let scenario = Scenario()
    await test(scenario.sut.$state.map(\.searchCurrencies)) { turbine in
      await turbine.expectInitial(value: [])
      let notFiltered = await turbine.value()
      #assert(notFiltered == Currency.samples.all())
      
      // when
      scenario.sut.send(.searchCurrencies(query: "Eur"))
      
      // then
      let filtered = await turbine.value()
      #assert(filtered == [Currency.samples.eur])
    }
  }
  
  func test_whenSearch_queryIsSaved() async {
    // given
    let scenario = Scenario()
    
    // when
    scenario.sut.send(.searchCurrencies(query: "Eur"))
    
    await test(scenario.sut.$state.map(\.searchQuery)) { turbine in
      await turbine.expectInitial(value: "")
      
      // then
      let result = await turbine.value()
      #assert(result == "Eur")
    }
  }
}

private class Scenario {
  
  let sut: ConverterViewModel
  
  let converterRepository: FakeConverterRepository
  
  init(
    converterRepository: FakeConverterRepository,
    currencyRepository: CurrencyRepository,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.converterRepository = converterRepository
    self.sut = ConverterViewModel(
      converterRepository: converterRepository,
      currencyRepository: currencyRepository,
      initialState: initialState
    )
  }
  
  convenience init(
    currencies: [Currency] = Currency.samples.all(),
    currencyRates: CurrencyRates = .samples.all,
    selectedCurrencies: SelectedCurrencies = SelectedCurrencies.initial,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.init(
      converterRepository: FakeConverterRepository(
        selectedCurrencies: selectedCurrencies
      ),
      currencyRepository: FakeCurrencyRepository(
        currencies: currencies,
        currencyRates: currencyRates
      ),
      initialState: initialState
    )
  }
}

private extension CurrencyValue {
  static func ~=(currencyValue: CurrencyValue, value: Double) -> Bool {
    let accuracy = 0.5
    return currencyValue.value > value - accuracy && currencyValue.value < value + accuracy
  }
}
// swiftlint:enable function_body_length
