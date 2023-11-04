import ConverterDomain
import CurrencyDomain
import SwiftData
import SwiftlyUtils

public struct FavoriteCurrenciesStorageModel {
  let currencyCodes: [FavoriteCurrencyPosition: CurrencyCode]
}

public struct FavoriteCurrencyPosition: Comparable, Decodable, Encodable, Hashable {
  
  let value: Int
  
  public init(value: Int) {
    self.value = value
  }
  
  public static func < (lhs: FavoriteCurrencyPosition, rhs: FavoriteCurrencyPosition) -> Bool {
    lhs.value < rhs.value
  }
}

@Model
public class FavoriteCurrenciesSwiftDataModel {
  @Attribute(.unique) public let id = 0
  var currencyCodes: [FavoriteCurrencyPosition: CurrencyCode]
  
  init(currencyCodes: [FavoriteCurrencyPosition: CurrencyCode]) {
    self.currencyCodes = currencyCodes
  }
  
  func replaceAt(position: Int, newValue: CurrencyCode) {
    currencyCodes.updateValue(newValue, forKey: FavoriteCurrencyPosition(value: position))
  }
}

extension FavoriteCurrenciesStorageModel {
  
  public func toDomainModel() -> FavoriteCurrencies {
    let maxFavoritePosition = currencyCodes.max(by: { c1, c2 in c1.key > c2.key })?.key.value ?? 0
    let maxPosition = max(maxFavoritePosition, FavoriteCurrencies.initial.currencyCodes.endIndex)
    
    var nonFavoriteInitials = FavoriteCurrencies.initial.currencyCodes
      .filter { code in !currencyCodes.contains(where: { favoriteE in favoriteE.value == code }) }
    var dict = [Int: CurrencyCode]()
    for i in 0...maxPosition {
      let code = currencyCodes[FavoriteCurrencyPosition(value: i)] ?? nonFavoriteInitials.removeFirstOrNil()
      if let c = code {
        dict[i] = c
      }
    }
    
    return FavoriteCurrencies.of(
      currencyCodes: dict.sorted { e1, e2 in e1.key < e2.key }.map(\.value)
    )
  }
  
  func toSwiftDataModel() -> FavoriteCurrenciesSwiftDataModel {
    FavoriteCurrenciesSwiftDataModel(
      currencyCodes: currencyCodes
    )
  }
}

extension FavoriteCurrenciesSwiftDataModel {
  
  func toStorageModel() -> FavoriteCurrenciesStorageModel {
    FavoriteCurrenciesStorageModel(
      currencyCodes: currencyCodes
    )
  }
}
