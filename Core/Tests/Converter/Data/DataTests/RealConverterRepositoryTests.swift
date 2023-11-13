import XCTest

import ConverterStorage
import CurrencyStorage
@testable import ConverterData

final class RealConverterRepositoryTests: XCTestCase {
  
  func test_setCurrency_insertsCurrencySelected() async {
    // given
    let scenario = Scenario()
    
    // when
    await scenario.sut.setCurrencyAt(position: 0, currency: .samples.eur)
    
    // then
    XCTAssertEqual(1, scenario.currencyStorage.selectedCurrencies[.samples.eur])
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
}
