import XCTest

import Combine
import CommonTest
import CurrencyDomain
@testable import ConverterPresentation

final class ConverterViewModelTests: XCTestCase {
  
  func test_loadAllCurrencies() async {
    // given
    let scenario = Scenario(
      currencies: [Currency.samples.eur]
    )
    
    // when
    await test(scenario.sut.$state.map(\.allCurrencies)) { turbine in
      await turbine.expectInitial(value: [])
      
      // then
      let result = await turbine.value()
      XCTAssertEqual(result, [Currency.samples.eur])
    }
  }
  
  func test_loadCurrencyValues() async {
    // given
    let scenario = Scenario(
      currencies: [Currency.samples.usd],
      currencyRates: [CurrencyRate.samples.usd]
    )
    
    // when
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      // then
      let result = await turbine.value()
      XCTAssertEqual(result.count, 1)
      XCTAssertEqual(result.first?.currency, Currency.samples.usd)
      XCTAssertEqual(result.first?.rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(result.first?.value, 10)
    }
  }
  
  func test_whenValueUpdate_currentRateIsUpdated() async {
    // given
    let scenario = Scenario(
      currencies: [Currency.samples.usd],
      currencyRates: [CurrencyRate.samples.usd]
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      XCTAssertEqual(before.count, 1)
      XCTAssertEqual(before.first?.currency, Currency.samples.usd)
      XCTAssertEqual(before.first?.rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(before.first?.value, 10)
      
      // when
      scenario.sut.send(
        .valueUpdate(
          currencyValue: CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.usd)
        )
      )
      
      // then
      let after = await turbine.value()
      XCTAssertEqual(after.count, 1)
      XCTAssertEqual(after.first?.currency, Currency.samples.usd)
      XCTAssertEqual(after.first?.rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(after.first?.value, 20)
    }
  }
}

private class Scenario {
  
  let sut: ConverterViewModel
  
  init(
    repository: CurrencyRepository,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.sut = ConverterViewModel(
      repository: repository,
      initialState: initialState
    )
  }
  
  convenience init(
    currencies: [Currency] = [],
    currencyRates: [CurrencyRate] = [],
    initialState: ConverterState = ConverterState.initial
  ) {
    self.init(
      repository: FakeCurrencyRepository(
        currencies: currencies,
        currencyRates: currencyRates
      ),
      initialState: initialState
    )
  }
}
