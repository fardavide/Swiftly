// swiftlint:disable function_body_length
import XCTest

import Combine
import ConverterDomain
import CurrencyDomain
import SwiftlyTest
@testable import ConverterPresentation

final class ConverterViewModelTests: XCTestCase {

  private let accuracy = 0.5

  func test_loadAllCurrencies() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all(),
      selectedCurrencies: .samples.alphabetical
    )

    // when
    await test(scenario.sut.$state.map(\.searchCurrencies)) { turbine in
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
      selectedCurrencies: .samples.alphabetical
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
      XCTAssertEqual(result[1].value, 81, accuracy: self.accuracy)

      XCTAssertEqual(result[2].currency, .samples.eur)
      XCTAssertEqual(result[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(result[2].value, 10, accuracy: self.accuracy)

      XCTAssertEqual(result[3].currency, .samples.gbp)
      XCTAssertEqual(result[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(result[3].value, 9, accuracy: self.accuracy)

      XCTAssertEqual(result[4].currency, .samples.jpy)
      XCTAssertEqual(result[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(result[4].value, 1667, accuracy: self.accuracy)

      XCTAssertEqual(result[5].currency, .samples.usd)
      XCTAssertEqual(result[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(result[5].value, 11, accuracy: self.accuracy)
    }
  }

  func test_whenValueUpdate_ratesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all(),
      selectedCurrencies: .samples.alphabetical
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
      XCTAssertEqual(before[1].value, 81, accuracy: self.accuracy)

      XCTAssertEqual(before[2].currency, .samples.eur)
      XCTAssertEqual(before[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(before[2].value, 10, accuracy: self.accuracy)

      XCTAssertEqual(before[3].currency, .samples.gbp)
      XCTAssertEqual(before[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(before[3].value, 9, accuracy: self.accuracy)

      XCTAssertEqual(before[4].currency, .samples.jpy)
      XCTAssertEqual(before[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(before[4].value, 1667, accuracy: self.accuracy)

      XCTAssertEqual(before[5].currency, .samples.usd)
      XCTAssertEqual(before[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(before[5].value, 11, accuracy: self.accuracy)

      // when
      scenario.sut.send(
        .updateValue(
          currencyValue: CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.usd)
        )
      )

      // then
      let after = await turbine.value()
      XCTAssertEqual(after.count, 6)

      XCTAssertEqual(after[0].currency, .samples.chf)
      XCTAssertEqual(after[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(after[0].value, 18, accuracy: self.accuracy)

      XCTAssertEqual(after[1].currency, .samples.cny)
      XCTAssertEqual(after[1].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(after[1].value, 146, accuracy: self.accuracy)

      XCTAssertEqual(after[2].currency, .samples.eur)
      XCTAssertEqual(after[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(after[2].value, 18, accuracy: self.accuracy)

      XCTAssertEqual(after[3].currency, .samples.gbp)
      XCTAssertEqual(after[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(after[3].value, 16, accuracy: self.accuracy)

      XCTAssertEqual(after[4].currency, .samples.jpy)
      XCTAssertEqual(after[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(after[4].value, 3000, accuracy: self.accuracy)

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
      selectedCurrencies: .samples.alphabetical
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
      XCTAssertEqual(before[1].value, 81, accuracy: self.accuracy)

      XCTAssertEqual(before[2].currency, .samples.eur)
      XCTAssertEqual(before[2].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(before[2].value, 10, accuracy: self.accuracy)

      XCTAssertEqual(before[3].currency, .samples.gbp)
      XCTAssertEqual(before[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(before[3].value, 9, accuracy: self.accuracy)

      XCTAssertEqual(before[4].currency, .samples.jpy)
      XCTAssertEqual(before[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(before[4].value, 1667, accuracy: self.accuracy)

      XCTAssertEqual(before[5].currency, .samples.usd)
      XCTAssertEqual(before[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(before[5].value, 11, accuracy: self.accuracy)

      // when
      scenario.sut.send(
        .changeCurrency(
          prev: Currency.samples.eur,
          new: Currency.samples.cny
        )
      )

      // then
      let after = await turbine.value()
      XCTAssertEqual(after.count, 6)

      XCTAssertEqual(after[0].currency, .samples.chf)
      XCTAssertEqual(after[0].rate, CurrencyRate.samples.chf.rate)
      XCTAssertEqual(after[0].value, 1, accuracy: self.accuracy)

      XCTAssertEqual(after[1].currency, .samples.eur)
      XCTAssertEqual(after[1].rate, CurrencyRate.samples.eur.rate)
      XCTAssertEqual(after[1].value, 1.2, accuracy: self.accuracy)

      XCTAssertEqual(after[2].currency, .samples.cny)
      XCTAssertEqual(after[2].rate, CurrencyRate.samples.cny.rate)
      XCTAssertEqual(after[2].value, 10)

      XCTAssertEqual(after[3].currency, .samples.gbp)
      XCTAssertEqual(after[3].rate, CurrencyRate.samples.gbp.rate)
      XCTAssertEqual(after[3].value, 1, accuracy: self.accuracy)

      XCTAssertEqual(after[4].currency, .samples.jpy)
      XCTAssertEqual(after[4].rate, CurrencyRate.samples.jpy.rate)
      XCTAssertEqual(after[4].value, 205, accuracy: self.accuracy)

      XCTAssertEqual(after[5].currency, .samples.usd)
      XCTAssertEqual(after[5].rate, CurrencyRate.samples.usd.rate)
      XCTAssertEqual(after[5].value, 1, accuracy: self.accuracy)
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
    currencies: [Currency] = [],
    currencyRates: [CurrencyRate] = [],
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
// swiftlint:enable function_body_length
