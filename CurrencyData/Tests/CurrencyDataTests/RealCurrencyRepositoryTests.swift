import XCTest

import CommonDate
import CommonNetwork
import CommonStorage
import CurrencyApi
import CurrencyDomain
import CurrencyStorage
@testable import CurrencyData

final class RealCurrencyRepositoryTests: XCTestCase {
  
  func test_whenEmptyCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: []
    )
    
    // when
    _ = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertTrue(scenario.api.didFetch)
  }
  
  func test_whenEmptyCache_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.samples.eurOnly,
      fetchAllRatesStorageModels: []
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success([CurrencyRate.samples.eur]))
  }
  
  func test_whenErrorFromCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiResult: .success(CurrencyRatesApiModel.samples.all),
      fetchAllRatesStorageResult: .failure(.unknown),
      updateDate: currentDate - 2.hours()
    )
    
    // when
    _ = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertTrue(scenario.api.didFetch)
  }
  
  func test_whenErrorFromCache_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiResult: .success(CurrencyRatesApiModel.samples.eurOnly),
      fetchAllRatesStorageResult: .failure(.unknown),
      updateDate: currentDate - 2.hours()
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success([CurrencyRate.samples.eur]))
  }
  
  func test_whenCacheNotExpired_dontFetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: CurrencyRateStorageModel.samples.all(),
      updateDate: currentDate - 2.hours()
    )
    
    // when
    _ = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertFalse(scenario.api.didFetch)
  }
  
  func test_whenCacheNotExpired_returnsResultFromStorage() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: [CurrencyRateStorageModel.samples.eur],
      updateDate: currentDate - 2.hours()
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success([CurrencyRate.samples.eur]))
  }
  
  func test_whenCacheExpired_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.samples.all,
      fetchAllRatesStorageModels: [CurrencyRateStorageModel.samples.eur],
      updateDate: currentDate - 3.days()
    )
    
    // when
    _ = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertTrue(scenario.api.didFetch)
  }
  
  func test_whenCacheExpired_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.samples.eurOnly,
      fetchAllRatesStorageModels: [CurrencyRateStorageModel.samples.usd],
      updateDate: currentDate - 3.days()
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success([CurrencyRate.samples.eur]))
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
    latestApiResult: Result<CurrencyRatesApiModel, ApiError>,
    fetchAllRatesStorageResult: Result<[CurrencyRateStorageModel], StorageError>,
    updateDate: Date = Date.distantPast
  ) {
    self.init(
      api: FakeCurrencyApi(latestResult: latestApiResult),
      storage: FakeCurrencyStorage(
        fetchAllRatesResult: fetchAllRatesStorageResult,
        updateDate: updateDate.toCurrencyDateStorageModel()
      )
    )
  }

  convenience init(
    latestApiModel: CurrencyRatesApiModel? = nil,
    fetchAllRatesStorageModels: [CurrencyRateStorageModel]? = nil,
    updateDate: Date = Date.distantPast
) {
    self.init(
      latestApiResult: 
        latestApiModel != nil ? .success(latestApiModel!) : .failure(.unknown),
      fetchAllRatesStorageResult:
        fetchAllRatesStorageModels != nil ? .success(fetchAllRatesStorageModels!) : .failure(.unknown),
      updateDate: updateDate
    )
  }
}
