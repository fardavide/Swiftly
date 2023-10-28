//
//  CurrencyRatesDto.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

public struct CurrencyRatesDto: Codable {
  let meta: Meta
  let data: [String: Currency]
  
  struct Meta: Codable {
    let lastUpdatedAt: String
    
    enum CodingKeys: String, CodingKey {
      case lastUpdatedAt = "last_updated_at"
    }
  }
  
  struct Currency: Codable {
    let code: String
    let value: Double
  }
}

public extension CurrencyRatesDto {
  static let sample = CurrencyRatesDto(
    meta: CurrencyRatesDto.Meta(
      lastUpdatedAt: "now"
    ),
    data: [
      "EUR": CurrencyRatesDto.Currency(
        code: "EUR",
        value: 1
      ),
      "USD": CurrencyRatesDto.Currency(
        code: "USD",
        value: 0.7
      ),
    ]
  )
}
