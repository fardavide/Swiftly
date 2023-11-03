import ConverterDomain
import CurrencyDomain
import SwiftData

public struct FavoriteCurrenciesStorageModel {
  let currencyCodes: [CurrencyCode]
}

@Model
class FavoriteCurrenciesSwiftDataModel {
  @Attribute(.unique) let id = 0
  var currencyCodes: [String]
  
  init(currencyCodes: [String]) {
    self.currencyCodes = currencyCodes
  }
}

extension FavoriteCurrenciesStorageModel {
  
  public func toDomainModel() -> FavoriteCurrencies {
    FavoriteCurrencies.of(currencyCodes: currencyCodes)
  }
  
  func toSwiftDataModel() -> FavoriteCurrenciesSwiftDataModel {
    FavoriteCurrenciesSwiftDataModel(
      currencyCodes: currencyCodes.map(\.value)
    )
  }
}

extension FavoriteCurrenciesSwiftDataModel {
  
  func toStorageModel() -> FavoriteCurrenciesStorageModel {
    FavoriteCurrenciesStorageModel(
      currencyCodes: currencyCodes.map { CurrencyCode(value: $0) }
    )
  }
}
