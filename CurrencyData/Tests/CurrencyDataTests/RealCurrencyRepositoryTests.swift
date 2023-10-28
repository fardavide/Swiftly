import XCTest

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
      latestApiModel: CurrencyRatesApiModel.sample,
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
      latestApiModel: CurrencyRatesApiModel.sample,
      fetchAllRatesStorageModels: []
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success(CurrencyRate.samples.all()))
  }
  
  func test_whenErrorFromCache_fetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiResult: .success(CurrencyRatesApiModel.sample),
      fetchAllRatesStorageResult: .failure(.unknown)
    )
    
    // when
    _ = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertTrue(scenario.api.didFetch)
  }
  
  func test_whenErrorFromCache_returnsResultFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiResult: .success(CurrencyRatesApiModel.sample),
      fetchAllRatesStorageResult: .failure(.unknown)
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success(CurrencyRate.samples.all()))
  }
  
  func test_whenCache_dontFetchFromApi() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.sample,
      fetchAllRatesStorageModels: CurrencyRateStorageModel.samples.all()
    )
    
    // when
    _ = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertFalse(scenario.api.didFetch)
  }
  
  func test_whenCache_returnsResultFromStorage() async throws {
    // given
    let scenario = Scenario(
      latestApiModel: CurrencyRatesApiModel.sample,
      fetchAllRatesStorageModels: CurrencyRateStorageModel.samples.all()
    )
    
    // when
    let result = await scenario.sut.getLatestRates()
    
    // then
    XCTAssertEqual(result, .success(CurrencyRate.samples.all()))
  }
}

private final class Scenario {
  let sut: RealCurrencyRepository
  let api: FakeCurrencyApi
  
  init(
    api: FakeCurrencyApi = FakeCurrencyApi(),
    storage: CurrencyStorage = FakeCurrencyStorage()
  ) {
    self.sut = RealCurrencyRepository(
      api: api,
      storage: storage
    )
    self.api = api
  }
  
  convenience init(
    latestApiResult: Result<CurrencyRatesApiModel, ApiError>,
    fetchAllRatesStorageResult: Result<[CurrencyRateStorageModel], StorageError>,
    fetchDate: FetchDateStorageModel = FetchDateStorageModel.distantPast
  ) {
    self.init(
      api: FakeCurrencyApi(latestResult: latestApiResult),
      storage: FakeCurrencyStorage(
        fetchAllRatesResult: fetchAllRatesStorageResult,
        fetchDate: fetchDate
      )
    )
  }

  convenience init(
    latestApiModel: CurrencyRatesApiModel? = nil,
    fetchAllRatesStorageModels: [CurrencyRateStorageModel]? = nil,
    fetchDate: FetchDateStorageModel = FetchDateStorageModel.distantPast
) {
    self.init(
      latestApiResult: 
        latestApiModel != nil ? .success(latestApiModel!) : .failure(.unknown),
      fetchAllRatesStorageResult:
        fetchAllRatesStorageModels != nil ? .success(fetchAllRatesStorageModels!) : .failure(.unknown),
      fetchDate: fetchDate
    )
  }
}
