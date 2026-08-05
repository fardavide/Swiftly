import Foundation

/// The URLs of one currency provider.
///
/// The protocol earns its keep with `hasApiKey`. `ApiKey.swift` is committed empty and filled from CI
/// secrets at build time, so a build made outside that pipeline calls every provider with `apikey=` and
/// gets a `401` back — indistinguishable, from the outside, from a key that expired. Asking before we call
/// turns the guess into a fact the app can state.
protocol ApiEndpoints {
  var apiKey: String { get }
}

extension ApiEndpoints {

  var hasApiKey: Bool {
    !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

final class CurrencyApiComEndpoints: ApiEndpoints {
  let apiKey: String

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

final class CurrencyBeaconComEndpoints: ApiEndpoints {
  let apiKey: String

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
    components.host = "api.currencybeacon.com"
    components.path = "/v1/\(path)"
    components.queryItems = [
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "base", value: "USD")
    ]
    
    return if let url = components.url {
      url
    } else {
      preconditionFailure("Invalid url \(components)")
    }
  }
}

final class ExchangeRatesIoEndpoints: ApiEndpoints {
  let apiKey: String

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
