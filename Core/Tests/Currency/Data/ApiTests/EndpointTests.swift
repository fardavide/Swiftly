import Testing

@testable import CurrencyApi

@Suite("EndpointTests")
struct EndpointTests {
  
  private let apiKey = "api_key"
  
  @Test
  func currencyApiDotCom_currencies() {
    let url = CurrencyApiComEndpoints(apiKey: apiKey).currencies()
    #expect(url.absoluteString == "https://api.currencyapi.com/v3/currencies?apikey=api_key")
  }
  
  @Test
  func currencyApiDotCom_lastRates() {
    let url = CurrencyApiComEndpoints(apiKey: apiKey).lastRates()
    #expect(url.absoluteString == "https://api.currencyapi.com/v3/latest?apikey=api_key")
  }
  
  @Test
  func exchangeRatesDotIo_lastRates() {
    let url = ExchangeRatesIoEndpoints(apiKey: apiKey).lastRates()
    #expect(url.absoluteString == "https://api.exchangeratesapi.io/v1/latest?access_key=api_key")
  }
}
