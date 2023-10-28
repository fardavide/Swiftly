//
//  CurrencyRatesDto.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//
import CurrencyDomain

public struct CurrencyRatesApiModel: Codable {
  let meta: Meta
  public let data: [String: CurrencyRateApiModel]
  
  struct Meta: Codable {
    let lastUpdatedAt: String
    
    enum CodingKeys: String, CodingKey {
      case lastUpdatedAt = "last_updated_at"
    }
  }
}

public struct CurrencyRateApiModel: Codable {
  let code: String
  public let value: Double
}

public extension CurrencyRatesApiModel {
  
  static let sample = CurrencyRatesApiModel(
    meta: CurrencyRatesApiModel.Meta(
      lastUpdatedAt: "now"
    ),
    data: [
      "EUR": CurrencyRateApiModel(
        code: "EUR",
        value: 1
      ),
      "USD": CurrencyRateApiModel(
        code: "USD",
        value: 0.7
      ),
    ]
  )
  
  func toDomainModels() -> [CurrencyRate] {
    self.data
      .filter { code, _ in Currency.from(code: code) != nil }
      .map { code, currencyDto in
        let currency = Currency.from(code: code)!
        return CurrencyRate(currency: currency, rate: currencyDto.value)
      }
  }
}
