//
//  CurrencyRatesDto.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

public struct CurrencyRatesDto: Codable {
  let meta: Meta
  public let data: [String: CurrencyRateDto]
  
  struct Meta: Codable {
    let lastUpdatedAt: String
    
    enum CodingKeys: String, CodingKey {
      case lastUpdatedAt = "last_updated_at"
    }
  }
  
  public struct CurrencyRateDto: Codable {
    let code: String
    public let value: Double
  }
}

public extension CurrencyRatesDto {
  static let sample = CurrencyRatesDto(
    meta: CurrencyRatesDto.Meta(
      lastUpdatedAt: "now"
    ),
    data: [
      "EUR": CurrencyRatesDto.CurrencyRateDto(
        code: "EUR",
        value: 1
      ),
      "USD": CurrencyRatesDto.CurrencyRateDto(
        code: "USD",
        value: 0.7
      ),
    ]
  )
}
