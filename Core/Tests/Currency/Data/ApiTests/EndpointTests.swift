import XCTest

import PowerAssert
@testable import CurrencyApi

final class EndpointTests: XCTestCase {
  
  private let apiKey = "api_key"
  
  func test_currencyApiDotCom_currencies() {
    let url = CurrencyApiComEndpoints(apiKey: apiKey).currencies()
    #assert(url.absoluteString == "https://api.currencyapi.com/v3/currencies?apikey=api_key")
  }
  
  func test_currencyApiDotCom_lastRates() {
    let url = CurrencyApiComEndpoints(apiKey: apiKey).lastRates()
    #assert(url.absoluteString == "https://api.currencyapi.com/v3/latest?apikey=api_key")
  }
  
  func test_exchangeRatesDotIo_lastRates() {
    let url = ExchangeRatesIoEndpoints(apiKey: apiKey).lastRates()
    #assert(url.absoluteString == "https://api.exchangeratesapi.io/v1/latest?access_key=api_key")
  }
}
