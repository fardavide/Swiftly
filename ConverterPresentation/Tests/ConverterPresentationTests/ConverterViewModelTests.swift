import XCTest

import Combine
import CommonTest
import ConverterDomain
import CurrencyDomain
@testable import ConverterPresentation

final class ConverterViewModelTests: XCTestCase {
  
  func test_loadAllCurrencies() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all(),
      favoriteCurrencies: .samples.alphabetical
    )
    
    // when
    await test(scenario.sut.$state.map(\.allCurrencies)) { turbine in
      await turbine.expectInitial(value: [])
      
      // then
      let result = await turbine.value()
      XCTAssertEqual(result, Currency.samples.all())
    }
  }
  
  func test_loadCurrencyValues() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all(),
      favoriteCurrencies: .samples.alphabetical
    )
    
    // when
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      // then
      let result = await turbine.value()
      XCTAssertEqual(result.count, 6)
      
      XCTAssertEqual(result[0].currency, .samples.chf)
      XCTAssertEqual(result[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(result[0].value, 10)
      
      XCTAssertEqual(result[1].currency, .samples.cny)
      XCTAssertEqual(result[1].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(result[1].value, 10)
      
      XCTAssertEqual(result[2].currency, .samples.eur)
      XCTAssertEqual(result[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(result[2].value, 10)
      
      XCTAssertEqual(result[3].currency, .samples.gbp)
      XCTAssertEqual(result[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(result[3].value, 10)
      
      XCTAssertEqual(result[4].currency, .samples.jpy)
      XCTAssertEqual(result[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(result[4].value, 10)
      
      XCTAssertEqual(result[5].currency, .samples.usd)
      XCTAssertEqual(result[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(result[5].value, 10)
    }
  }
  
  func test_whenValueUpdate_ratesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all(),
      favoriteCurrencies: .samples.alphabetical
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      XCTAssertEqual(before.count, 6)
      
      XCTAssertEqual(before[0].currency, .samples.chf)
      XCTAssertEqual(before[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(before[0].value, 10)
      
      XCTAssertEqual(before[1].currency, .samples.cny)
      XCTAssertEqual(before[1].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(before[1].value, 10)
      
      XCTAssertEqual(before[2].currency, .samples.eur)
      XCTAssertEqual(before[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(before[2].value, 10)
      
      XCTAssertEqual(before[3].currency, .samples.gbp)
      XCTAssertEqual(before[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(before[3].value, 10)
      
      XCTAssertEqual(before[4].currency, .samples.jpy)
      XCTAssertEqual(before[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(before[4].value, 10)
      
      XCTAssertEqual(before[5].currency, .samples.usd)
      XCTAssertEqual(before[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(before[5].value, 10)

      // when
      scenario.sut.send(
        .valueUpdate(
          currencyValue: CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.usd)
        )
      )
      
      // then
      let after = await turbine.value()
      XCTAssertEqual(after.count, 6)
      
      XCTAssertEqual(after[0].currency, .samples.chf)
      XCTAssertEqual(after[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(after[0].value.rounded(), 18)
      
      XCTAssertEqual(after[1].currency, .samples.cny)
      XCTAssertEqual(after[1].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(after[1].value.rounded(), 146)
      
      XCTAssertEqual(after[2].currency, .samples.eur)
      XCTAssertEqual(after[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(after[2].value.rounded(), 18)
      
      XCTAssertEqual(after[3].currency, .samples.gbp)
      XCTAssertEqual(after[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(after[3].value.rounded(), 16)
      
      XCTAssertEqual(after[4].currency, .samples.jpy)
      XCTAssertEqual(after[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(after[4].value.rounded(), 3000)
      
      XCTAssertEqual(after[5].currency, .samples.usd)
      XCTAssertEqual(after[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(after[5].value, 20)
    }
  }
  
  func test_whenCurrencyChange_otherRatesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all(),
      favoriteCurrencies: .samples.alphabetical
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      XCTAssertEqual(before.count, 6)
      
      XCTAssertEqual(before[0].currency, .samples.chf)
      XCTAssertEqual(before[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(before[0].value, 10)
      
      XCTAssertEqual(before[1].currency, .samples.cny)
      XCTAssertEqual(before[1].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(before[1].value, 10)
      
      XCTAssertEqual(before[2].currency, .samples.eur)
      XCTAssertEqual(before[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(before[2].value, 10)
      
      XCTAssertEqual(before[3].currency, .samples.gbp)
      XCTAssertEqual(before[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(before[3].value, 10)
      
      XCTAssertEqual(before[4].currency, .samples.jpy)
      XCTAssertEqual(before[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(before[4].value, 10)
      
      XCTAssertEqual(before[5].currency, .samples.usd)
      XCTAssertEqual(before[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(before[5].value, 10)
      
      // when
      scenario.sut.send(
        .currencyChange(
          prev: Currency.samples.eur,
          new: Currency.samples.usd
        )
      )
      
      // then
      let after = await turbine.value()
      XCTAssertEqual(after.count, 6)
      
      XCTAssertEqual(after[0].currency, .samples.chf)
      XCTAssertEqual(after[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(after[0].value, 10)
      
      XCTAssertEqual(after[1].currency, .samples.cny)
      XCTAssertEqual(after[1].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(after[1].value, 10)
      
      XCTAssertEqual(after[2].currency, .samples.usd)
      XCTAssertEqual(after[2].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(after[2].value, 10)
      
      XCTAssertEqual(after[3].currency, .samples.gbp)
      XCTAssertEqual(after[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(after[3].value, 10)
      
      XCTAssertEqual(after[4].currency, .samples.jpy)
      XCTAssertEqual(after[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(after[4].value, 10)
      
      XCTAssertEqual(after[5].currency, .samples.eur)
      XCTAssertEqual(after[5].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(after[5].value, 10)
    }
  }
}

private class Scenario {
  
  let sut: ConverterViewModel
  
  init(
    converterRepository: ConverterRepository,
    currencyRepository: CurrencyRepository,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.sut = ConverterViewModel(
      converterRepository: converterRepository,
      currencyRepository: currencyRepository,
      initialState: initialState
    )
  }
  
  convenience init(
    currencies: [Currency] = [],
    currencyRates: [CurrencyRate] = [],
    favoriteCurrencies: FavoriteCurrencies = FavoriteCurrencies.initial,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.init(
      converterRepository: FakeConverterRepository(
        favoriteCurrencies: favoriteCurrencies
      ),
      currencyRepository: FakeCurrencyRepository(
        currencies: currencies,
        currencyRates: currencyRates
      ),
      initialState: initialState
    )
  }
}
