import CurrencyDomain

struct CurrenciesCurrencyApiComModel: Codable, CurrenciesApiModel {
  let data: [String: CurrencyModel]
  
  func toDomainModels() -> [Currency] {
    data.map { code, currencyApiModel in
      Currency(
        code: CurrencyCode(value: code),
        name: currencyApiModel.name,
        symbol: currencyApiModel.symbol
      )
    }
  }
  
  struct CurrencyModel: Codable {
    let code: String
    let name: String
    let symbol: String
  }
}

extension CurrenciesCurrencyApiComModel.CurrencyModel {
    
  func toDomainModel() -> Currency {
    Currency(
      code: CurrencyCode(value: code),
      name: name,
      symbol: symbol
    )
  }
}
