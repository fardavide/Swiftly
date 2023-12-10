import Foundation

final class CurrencyApiComEndpoints {
  private let apiKey: String
  
  init(apiKey: String) {
    self.apiKey = apiKey
  }
  
  func currencies() -> URL {
    buildUrl(path: "currencies")
  }
  
  func lastRates() -> URL {
    buildUrl(path: "latest")
  }
  
  private func buildUrl(path: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.currencyapi.com"
    components.path = "/v3/\(path)"
    components.queryItems = [URLQueryItem(name: "apikey", value: apiKey)]
    
    return if let url = components.url {
      url
    } else {
      preconditionFailure("Invalid url \(components)")
    }
  }
}

final class ExchangeRatesIoEndpoints {
  private let apiKey: String
  
  init(apiKey: String) {
    self.apiKey = apiKey
  }
  
  func lastRates() -> URL {
    buildUrl(path: "latest")
  }
  
  private func buildUrl(path: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.exchangeratesapi.io"
    components.path = "/v1/\(path)"
    components.queryItems = [URLQueryItem(name: "access_key", value: apiKey)]
    
    return if let url = components.url {
      url
    } else {
      preconditionFailure("Invalid url \(components)")
    }
  }
}
