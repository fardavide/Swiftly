import AppIntents
import CurrencyDomain

struct CurrencyEntity: AppEntity {
  
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Currency"
  static let defaultQuery = CurrencyQuery()
  
  let id: String
  let name: String
  let rate: Double
  let symbol: String
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(stringLiteral: name)
  }
}

extension CurrencyEntity {
  func toDomainModel() -> CurrencyWithRate {
    CurrencyWithRate(
      currency: Currency(
        code: CurrencyCode(value: id),
        name: name,
        symbol: symbol
      ),
      rate: rate
    )
  }
}

extension CurrencyWithRate {
  func toEntity() -> CurrencyEntity {
    CurrencyEntity(
      id: currency.code.id,
      name: currency.name,
      rate: rate,
      symbol: currency.symbol
    )
  }
}
