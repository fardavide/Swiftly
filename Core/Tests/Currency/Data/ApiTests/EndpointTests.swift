import XCTest

import PowerAssert
@testable import CurrencyApi

final class EndpointTests: XCTestCase {
  
  private let apiKey = "api_key"
  
  func test_currencyApiDotCom_currencies() {
    // given
    let endpoints = Endpoints(for: .currencyApiDotCom, apiKey: apiKey)
    
    // when
    let url = endpoints.currencies()
    
    #assert(url.absoluteString == "https://api.currencyapi.com/v3/currencies?apikey=api_key")
  }
  
  func test_currencyApiDotCom_lastRates() {
    // given
    let endpoints = Endpoints(for: .currencyApiDotCom, apiKey: apiKey)
    
    // when
    let url = endpoints.lastRates()
    
    #assert(url.absoluteString == "https://api.currencyapi.com/v3/latest?apikey=api_key")
  }
}
