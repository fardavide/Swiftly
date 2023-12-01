import AppIntents
import CurrencyDomain

struct CurrencyEntity: AppEntity {
  
  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Currency"
  static let defaultQuery = CurrencyQuery()
  
  let id: String
  let name: String
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(stringLiteral: name)
  }
}

extension CurrencyWithRate {
  func toEntity() -> CurrencyEntity {
    CurrencyEntity(id: currency.code.id, name: currency.name)
  }
}
