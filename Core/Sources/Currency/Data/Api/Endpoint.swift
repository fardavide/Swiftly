import Foundation

struct Endpoints {
  private let service: CurrencyService
  private let apiKey: String
  
  init(for service: CurrencyService, apiKey: String) {
    self.service = service
    self.apiKey = apiKey
  }
  
  init(for service: CurrencyService) {
    self.init(for: service, apiKey: ApiKey.getFor(service: service))
  }
  
  func currencies() -> URL {
    buildUrl(path: .currencies)
  }
  
  func lastRates() -> URL {
    buildUrl(path: .lastRates)
  }
  
  private func buildUrl(path: ApiPath) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    switch service {
    case .currencyApiDotCom:
      components.host = "api.currencyapi.com"
      components.path = "/v3/\(path.string(for: service))"
      components.queryItems = [URLQueryItem(name: "apikey", value: apiKey)]
    case .exchangeRatesDotIo:
      fatalError("not implemented")
    }
    return if let url = components.url {
      url
    } else {
      preconditionFailure("Invalid url \(components)")
    }
  }
}

enum ApiPath {
  case currencies
  case lastRates
  
  func string(for service: CurrencyService) -> String {
    switch self {
    case .currencies: 
      switch service {
      case .currencyApiDotCom: "currencies"
      case .exchangeRatesDotIo: fatalError("not implemented")
      }
    case .lastRates:
      switch service {
      case .currencyApiDotCom: "latest"
      case .exchangeRatesDotIo: fatalError("not implemented")
      }
    }
  }
}
