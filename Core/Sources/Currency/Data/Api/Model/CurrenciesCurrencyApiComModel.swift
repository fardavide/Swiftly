import CurrencyDomain

struct CurrenciesCurrencyApiComModel: Codable, CurrenciesApiModel {
  let data: [String: CurrencyCurrencyApiDotComModel]
  
  func toDomainModels() -> [Currency] {
    self.data.map { code, currencyApiModel in
      Currency(
        code: CurrencyCode(value: code),
        name: currencyApiModel.name,
        symbol: currencyApiModel.symbol
      )
    }
  }
}

struct CurrencyCurrencyApiDotComModel: Codable {
  let code: String
  let name: String
  let symbol: String
}

extension CurrenciesCurrencyApiComModel {
  
  func any() -> AnyCurrenciesApiModel {
    AnyCurrenciesApiModel(self)
  }
}

extension CurrencyCurrencyApiDotComModel {
    
  func toDomainModel() -> Currency {
    Currency(
      code: CurrencyCode(value: code),
      name: name,
      symbol: symbol
    )
  }
}
