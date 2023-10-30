//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 30/10/23.
//

import Foundation

struct Endpoint {
  let path: String
}

extension Endpoint {
  
  static func currencties() -> Endpoint {
    Endpoint(path: "currencies")
  }
  
  static func latestRates() -> Endpoint {
    Endpoint(path: "latest")
  }
  
  var url: URL {
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
