// swiftlint:disable function_body_length
import Testing

import Combine
import ConverterDomain
import CurrencyDomain
import DateUtils
import Design
import SwiftlyTest
import SwiftlyUtils
@testable import ConverterPresentation

@MainActor
struct ConverterViewModelTests {
  
  @Test
  func loadAllCurrencies() async {
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
      #expect(result == Currency.samples.all())
    }
  }
  
  @Test
  func loadCurrencyValues() async {
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
      #expect(result.count == 6)
      
      #expect(result[0].currency == Currency.samples.chf)
      #expect(result[0].rate == CurrencyRate.samples.chf.rate)
      #expect(result[0].value == 10)
      
      #expect(result[1].currency == Currency.samples.cny)
      #expect(result[1].rate == CurrencyRate.samples.cny.rate)
      #expect(result[1] ~= 81)
      
      #expect(result[2].currency == Currency.samples.eur)
      #expect(result[2].rate == CurrencyRate.samples.eur.rate)
      #expect(result[2] ~= 10)
      
      #expect(result[3].currency == Currency.samples.gbp)
      #expect(result[3].rate == CurrencyRate.samples.gbp.rate)
      #expect(result[3] ~= 9)
      
      #expect(result[4].currency == Currency.samples.jpy)
      #expect(result[4].rate == CurrencyRate.samples.jpy.rate)
      #expect(result[4] ~= 1667)
      
      #expect(result[5].currency == Currency.samples.usd)
      #expect(result[5].rate == CurrencyRate.samples.usd.rate)
      #expect(result[5] ~= 11)
    }
  }
  
  @Test
  func whenValueUpdate_ratesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all,
      selectedCurrencies: .samples.alphabetical
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      #expect(before.count == 6)
      
      #expect(before[0].currency == Currency.samples.chf)
      #expect(before[0].rate == CurrencyRate.samples.chf.rate)
      #expect(before[0].value == 10)
      
      #expect(before[1].currency == Currency.samples.cny)
      #expect(before[1].rate == CurrencyRate.samples.cny.rate)
      #expect(before[1] ~= 81)
      
      #expect(before[2].currency == Currency.samples.eur)
      #expect(before[2].rate == CurrencyRate.samples.eur.rate)
      #expect(before[2] ~= 10)
      
      #expect(before[3].currency == Currency.samples.gbp)
      #expect(before[3].rate == CurrencyRate.samples.gbp.rate)
      #expect(before[3] ~= 9)
      
      #expect(before[4].currency == Currency.samples.jpy)
      #expect(before[4].rate == CurrencyRate.samples.jpy.rate)
      #expect(before[4] ~= 1667)
      
      #expect(before[5].currency == Currency.samples.usd)
      #expect(before[5].rate == CurrencyRate.samples.usd.rate)
      #expect(before[5] ~= 11)
      
      // when
      await scenario.sut.send(
        .updateValue(
          currencyValue: CurrencyValue(value: 20, currencyWithRate: CurrencyWithRate.samples.usd)
        )
      )
      
      // then
      let after = await turbine.value()
      #expect(after.count == 6)
      
      #expect(after[0].currency == Currency.samples.chf)
      #expect(after[0].rate == CurrencyRate.samples.chf.rate)
      #expect(after[0] ~= 18)
      
      #expect(after[1].currency == Currency.samples.cny)
      #expect(after[1].rate == CurrencyRate.samples.cny.rate)
      #expect(after[1] ~= 146)
      
      #expect(after[2].currency == Currency.samples.eur)
      #expect(after[2].rate == CurrencyRate.samples.eur.rate)
      #expect(after[2] ~= 18)
      
      #expect(after[3].currency == Currency.samples.gbp)
      #expect(after[3].rate == CurrencyRate.samples.gbp.rate)
      #expect(after[3] ~= 16)
      
      #expect(after[4].currency == Currency.samples.jpy)
      #expect(after[4].rate == CurrencyRate.samples.jpy.rate)
      #expect(after[4] ~= 3000)
      
      #expect(after[5].currency == Currency.samples.usd)
      #expect(after[5].rate == CurrencyRate.samples.usd.rate)
      #expect(after[5].value == 20)
    }
  }
  @Test
  func whenCurrencyChange_otherRatesAreUpdated() async {
    // given
    let scenario = Scenario(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all,
      selectedCurrencies: .samples.alphabetical
    )
    
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      
      let before = await turbine.value()
      #expect(before.count == 6)
      
      #expect(before[0].currency == Currency.samples.chf)
      #expect(before[0].rate == CurrencyRate.samples.chf.rate)
      #expect(before[0].value == 10)
      
      #expect(before[1].currency == Currency.samples.cny)
      #expect(before[1].rate == CurrencyRate.samples.cny.rate)
      #expect(before[1] ~= 81)
      
      #expect(before[2].currency == Currency.samples.eur)
      #expect(before[2].rate == CurrencyRate.samples.eur.rate)
      #expect(before[2] ~= 10)
      
      #expect(before[3].currency == Currency.samples.gbp)
      #expect(before[3].rate == CurrencyRate.samples.gbp.rate)
      #expect(before[3] ~= 9)
      
      #expect(before[4].currency == Currency.samples.jpy)
      #expect(before[4].rate == CurrencyRate.samples.jpy.rate)
      #expect(before[4] ~= 1667)
      
      #expect(before[5].currency == Currency.samples.usd)
      #expect(before[5].rate == CurrencyRate.samples.usd.rate)
      #expect(before[5] ~= 11)
      
      // when
      await scenario.sut.send(
        .changeCurrency(
          prev: Currency.samples.eur,
          new: Currency.samples.cny
        )
      )
      
      // then
      let after = await turbine.value()
      #expect(after.count == 6)
      
      #expect(after[0].currency == Currency.samples.chf)
      #expect(after[0].rate == CurrencyRate.samples.chf.rate)
      #expect(after[0] ~= 1)
      
      #expect(after[1].currency == Currency.samples.eur)
      #expect(after[1].rate == CurrencyRate.samples.eur.rate)
      #expect(after[1] ~= 1.2)
      
      #expect(after[2].currency == Currency.samples.cny)
      #expect(after[2].rate == CurrencyRate.samples.cny.rate)
      #expect(after[2].value == 10)
      
      #expect(after[3].currency == Currency.samples.gbp)
      #expect(after[3].rate == CurrencyRate.samples.gbp.rate)
      #expect(after[3] ~= 1)
      
      #expect(after[4].currency == Currency.samples.jpy)
      #expect(after[4].rate == CurrencyRate.samples.jpy.rate)
      #expect(after[4] ~= 205)
      
      #expect(after[5].currency == Currency.samples.usd)
      #expect(after[5].rate == CurrencyRate.samples.usd.rate)
      #expect(after[5] ~= 1)
    }
  }
  
  @Test
  func whenSearch_currenciesAreFiltered() async {
    // given
    let scenario = Scenario()
    await test(scenario.sut.$state.map(\.searchCurrencies)) { turbine in
      await turbine.expectInitial(value: [])
      let notFiltered = await turbine.value()
      #expect(notFiltered == Currency.samples.all())
      
      // when
      await scenario.sut.send(.searchCurrencies(query: "Eur"))
      
      // then
      let filtered = await turbine.value()
      #expect(filtered == [Currency.samples.eur])
    }
  }
  
  @Test
  func whenSearch_queryIsSaved() async {
    // given
    let scenario = Scenario()
    
    // when
    await scenario.sut.send(.searchCurrencies(query: "Eur"))
    
    // then
    await test(scenario.sut.$state.map(\.searchQuery)) { turbine in
      await turbine.expectInitial(value: "")
      let query = await turbine.value()
      #expect(query == "Eur")
    }
  }

  /// A refresh that failed over cached data gets a banner, and the banner gets the typed reason: the whole
  /// point of `DataError`'s causes is that the user is told *which* failure they are looking at.
  @Test
  func whenRefreshFails_overCachedData_theBannerCarriesTheCause() async {
    // given
    let scenario = Scenario(
      currencyRatesResult: .successWithError(
        data: .samples.all,
        error: .network(cause: .noConnection)
      )
    )

    // when
    // `ErrorModel` carries an `SFSymbol`, which is a class and not `Sendable`, so it cannot be the value a
    // turbine hands across. Waiting on the values — set in the same `emit` block, right after the banner —
    // and then reading the state is the same instant, without the isolation problem.
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      _ = await turbine.value()

      // then
      let expected = DataError.network(cause: .noConnection).toErrorModel()
      #expect(scenario.sut.state.refreshError == expected)
    }
  }

  /// A cancelled refresh is the app's own doing — the screen went away, or a newer refresh replaced this
  /// one — so there is nothing to tell the user about it.
  @Test
  func whenRefreshIsCancelled_thereIsNoBanner() async {
    // given
    let scenario = Scenario(
      currencyRatesResult: .successWithError(
        data: .samples.all,
        error: .network(cause: .cancelled)
      )
    )

    // when
    await test(scenario.sut.$state.map(\.values)) { turbine in
      await turbine.expectInitial(value: [])
      _ = await turbine.value()

      // then
      #expect(scenario.sut.state.refreshError == nil)
    }
  }
}
  
@MainActor
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

  /// For the partial-failure cases: data *and* an error, which is what a repository returns when the
  /// network refused but the cache had something to show.
  convenience init(
    currenciesResult: DataResult<[Currency]> = .success(Currency.samples.all()),
    currencyRatesResult: DataResult<CurrencyRates>,
    selectedCurrencies: SelectedCurrencies = .samples.alphabetical
  ) {
    self.init(
      converterRepository: FakeConverterRepository(
        selectedCurrencies: selectedCurrencies
      ),
      currencyRepository: FakeCurrencyRepository(
        currenciesResult: currenciesResult,
        currencyRatesResult: currencyRatesResult
      )
    )
  }
}

private extension CurrencyValue {
  static func ~= (currencyValue: CurrencyValue, value: Double) -> Bool {
    let accuracy = 0.5
    return currencyValue.value > value - accuracy && currencyValue.value < value + accuracy
  }
}
// swiftlint:enable function_body_length
