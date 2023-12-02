// swiftlint:disable file_length
import XCTest

import CurrencyApi
import CurrencyDomain
import CurrencyStorage
import DateUtils
import Network
import PowerAssert
import SwiftlyStorage
import SwiftlyUtils
@testable import CurrencyData

final class RealCurrencyRepositoryTests: XCTestCase {

  // MARK: - latest rates
  func testLatestRates_whenEmptyCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: []
    )

    // when
    _ = await scenario.sut.getLatestRates()

    // then
    #assert(scenario.api.didFetchLatestRates)
  }

  func testLatestRates_whenEmptyCache_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiModel: CurrencyRatesApiModel.samples.eurOnly,
      fetchAllRatesStorageModels: []
    )

    // when
    let result = await scenario.sut.getLatestRates()

    // then
    #assert(result == .success([CurrencyRate.samples.eur].updatedAt(currentDate)))
  }

  func testLatestRates_whenErrorFromCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiResult: .success(CurrencyRatesApiModel.samples.all),
      fetchAllRatesStorageResult: .failure(.unknown),
      updateDate: currentDate - 2.hours()
    )

    // when
    _ = await scenario.sut.getLatestRates()

    // then
    #assert(scenario.api.didFetchLatestRates)
  }

  func testLatestRates_whenErrorFromCache_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiResult: .success(CurrencyRatesApiModel.samples.eurOnly),
      fetchAllRatesStorageResult: .failure(.unknown),
      updateDate: currentDate - 2.hours()
    )

    // when
    let result = await scenario.sut.getLatestRates()

    // then
    #assert(result == .success([CurrencyRate.samples.eur].updatedAt(currentDate)))
  }

  func testLatestRates_whenCacheNotExpired_dontFetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: CurrencyRateStorageModel.samples.all(),
      updateDate: currentDate - 2.hours()
    )

    // when
    _ = await scenario.sut.getLatestRates()

    // then
    #assert(scenario.api.didFetchLatestRates.not())
  }

  func testLatestRates_whenCacheNotExpired_returnsResultFromStorage() async throws {
    // given
    let updateDate = currentDate - 2.hours()
    let scenario = Scenario(
      latestRatesApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: [CurrencyRateStorageModel.samples.eur],
      updateDate: updateDate
    )

    // when
    let result = await scenario.sut.getLatestRates()

    // then
    #assert(result == .success([CurrencyRate.samples.eur].updatedAt(updateDate)))
  }

  func testLatestRates_whenCacheExpired_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: [CurrencyRateStorageModel.samples.eur],
      updateDate: currentDate - 3.days()
    )

    // when
    _ = await scenario.sut.getLatestRates()

    // then
    #assert(scenario.api.didFetchLatestRates)
  }

  func testLatestRates_whenCacheExpired_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestRatesApiModel: CurrencyRatesApiModel.samples.eurOnly,
      fetchAllRatesStorageModels: [CurrencyRateStorageModel.samples.usd],
      updateDate: currentDate - 3.days()
    )

    // when
    let result = await scenario.sut.getLatestRates()

    // then
    #assert(result == .success(.samples.eurOnly))
  }

  // MARK: - all currencies
  func testCurrencies_whenEmptyCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      currenciesApiModel: CurrenciesApiModel.samples.all,
      fetchCurrenciesStorageModels: []
    )

    // when
    _ = await scenario.sut.getCurrencies()

    // then
    #assert(scenario.api.didFetchCurrencies)
  }

  func testCurrencies_whenEmptyCache_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      currenciesApiModel: CurrenciesApiModel.samples.eurOnly,
      fetchCurrenciesStorageModels: []
    )

    // when
    let result = await scenario.sut.getCurrencies()

    // then
    #assert(result == .success([Currency.samples.eur]))
  }

  func testCurrencies_whenErrorFromCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      currenciesApiResult: .success(CurrenciesApiModel.samples.all),
      fetchAllCurrenciesStorageResult: .failure(.unknown)
    )

    // when
    _ = await scenario.sut.getCurrencies()

    // then
    #assert(scenario.api.didFetchCurrencies)
  }

  func testCurrencies_whenErrorFromCache_returnsResultFromApi() async {
    // given
    let scenario = Scenario(
      currenciesApiResult: .success(CurrenciesApiModel.samples.eurOnly),
      fetchAllCurrenciesStorageResult: .failure(.unknown)
    )

    // when
    let result = await scenario.sut.getCurrencies()

    // then
    #assert(result == .success([Currency.samples.eur]))
  }
  
  func testCurrencies_whenNotExpiredCache_fetchFromStorage() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all(),
      updateDate: currentDate
    )
    
    // when
    _ = await scenario.sut.getCurrencies()
    
    // then
    #assert(scenario.api.didFetchCurrencies.not())
  }
  
  func testCurrencies_whenNotExpiredCache_returnsResultFromStorage() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all(),
      updateDate: currentDate
    )
    
    // when
    let result = await scenario.sut.getCurrencies()
    
    // then
    #assert(result == .success(Currency.samples.all()))
  }
  
  func testCurrencies_whenExpiredCache_fetchFromApi() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all(),
      updateDate: currentDate - 25.hours()
    )
    
    // when
    _ = await scenario.sut.getCurrencies()
    
    // then
    #assert(scenario.api.didFetchCurrencies)
  }
  
  func testCurrencies_whenExpiredCache_returnsResultFromApi() async {
    // given
    let scenario = Scenario(
      currenciesApiModel: CurrenciesApiModel.samples.usdOnly,
      fetchCurrenciesStorageModels: [CurrencyStorageModel.samples.eur],
      updateDate: currentDate - 25.hours()
    )
    
    // when
    let result = await scenario.sut.getCurrencies()
    
    // then
    #assert(result == .success([Currency.samples.usd]))
  }

  // MARK: - search currencies
  func testSearchCurrencies_whenEmpty_returnsAllCurrencies() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "", sorting: .alphabetical)

    // then
    #assert(result == .success(Currency.samples.all()))
  }
  
  func testSearchCurrencies_whenMatchFullNameSameCase_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "Euro", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.eur]))
  }

  func testSearchCurrencies_whenMatchFullNameDifferentCase_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "eUrO", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.eur]))
  }

  func testSearchCurrencies_whenMatchPartialName_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "ur", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.eur]))
  }

  func testSearchCurrencies_whenMatchFullCodeSameCase_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all().print()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "CNY", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.cny]))
  }

  func testSearchCurrencies_whenMatchFullCodeDifferentCase_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "CnY", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.cny]))
  }

  func testSearchCurrencies_whenMatchPartialCode_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "Y", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.cny, .samples.jpy]))
  }

  func testSearchCurrencies_whenMatchFullSymbolSameCase_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "CN¥", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.cny]))
  }

  func testSearchCurrencies_whenMatchFullSymbolDifferentCase_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "Cn¥", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.cny]))
  }

  func testSearchCurrencies_whenMatchPartialSymbol_returnsFilteredResults() async {
    // given
    let scenario = Scenario(
      fetchCurrenciesStorageModels: CurrencyStorageModel.samples.all()
    )

    // when
    let result = await scenario.sut.searchCurrencies(query: "¥", sorting: .alphabetical)

    // then
    #assert(result == .success([Currency.samples.cny, .samples.jpy]))
  }
}

private let currentDate = Date.samples.xmas2023noon

private final class Scenario {
  let api: FakeCurrencyApi
  let sut: RealCurrencyRepository

  init(
    api: FakeCurrencyApi = FakeCurrencyApi(),
    storage: CurrencyStorage = FakeCurrencyStorage()
  ) {
    self.sut = RealCurrencyRepository(
      api: api,
      getCurrentDate: FakeGetCurrentDate(date: currentDate),
      storage: storage
    )
    self.api = api
  }

  convenience init(
    currenciesApiResult: Result<CurrenciesApiModel, ApiError> =
      .failure(.unknown),
    fetchAllCurrenciesStorageResult: Result<[CurrencyStorageModel], StorageError> =
      .failure(.unknown),
    latestRatesApiResult: Result<CurrencyRatesApiModel, ApiError> =
      .failure(.unknown),
    fetchAllRatesStorageResult: Result<[CurrencyRateStorageModel], StorageError> =
      .failure(.unknown),
    updateDate: Date = Date.distantPast
  ) {
    self.init(
      api: FakeCurrencyApi(
        currenciesResult: currenciesApiResult,
        latestRatesResult: latestRatesApiResult
      ),
      storage: FakeCurrencyStorage(
        fetchAllCurrenciesResult: fetchAllCurrenciesStorageResult,
        fetchAllRatesResult: fetchAllRatesStorageResult,
        updateDate: updateDate.toCurrencyDateStorageModel()
      )
    )
  }

  convenience init(
    currenciesApiModel: CurrenciesApiModel? = nil,
    fetchCurrenciesStorageModels: [CurrencyStorageModel]? = nil,
    latestRatesApiModel: CurrencyRatesApiModel? = nil,
    fetchAllRatesStorageModels: [CurrencyRateStorageModel]? = nil,
    updateDate: Date = currentDate
  ) {
    self.init(
      currenciesApiResult:
        currenciesApiModel != nil ? .success(currenciesApiModel!) : .failure(.unknown),
      fetchAllCurrenciesStorageResult:
        fetchCurrenciesStorageModels != nil ? .success(fetchCurrenciesStorageModels!) : .failure(.unknown),
      latestRatesApiResult:
        latestRatesApiModel != nil ? .success(latestRatesApiModel!) : .failure(.unknown),
      fetchAllRatesStorageResult:
        fetchAllRatesStorageModels != nil ? .success(fetchAllRatesStorageModels!) : .failure(.unknown),
      updateDate: updateDate
    )
  }
}
// swiftlint:enable file_length
