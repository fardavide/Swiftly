import CurrencyDomain
import Foundation

struct CurrenciesCurrencyBeaconComModel: Codable, CurrenciesApiModel {
  let response: [CurrencyModel]
  
  func toDomainModels() -> [Currency] {
    response.map { currency in
      Currency(
        code: CurrencyCode(value: currency.code),
        name: currency.name,
        symbol: currency.symbol
      )
    }.sorted { $0.name < $1.name }
  }
  
  struct CurrencyModel: Codable {
    let code: String
    let name: String
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
      case code = "short_code"
      case name = "name"
      case symbol = "symbol"
    }
  }
}
