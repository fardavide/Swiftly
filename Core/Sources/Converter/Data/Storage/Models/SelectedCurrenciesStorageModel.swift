import ConverterDomain
import CurrencyDomain
import SwiftData
import SwiftlyUtils

public struct SelectedCurrenciesStorageModel {
  
  public init(currencyCodes: [SelectedCurrencyPosition: CurrencyCode]) {
    self.currencyCodes = currencyCodes
  }
  
  let currencyCodes: [SelectedCurrencyPosition: CurrencyCode]
}

public struct SelectedCurrencyPosition: Comparable, Decodable, Encodable, Hashable {

  let value: Int

  public init(value: Int) {
    self.value = value
  }

  public static func < (lhs: SelectedCurrencyPosition, rhs: SelectedCurrencyPosition) -> Bool {
    lhs.value < rhs.value
  }
}

@Model
public class SelectedCurrenciesSwiftDataModel {
  @Attribute(.unique) public let id = 0
  var currencyCodes: [SelectedCurrencyPosition: CurrencyCode]

  init(currencyCodes: [SelectedCurrencyPosition: CurrencyCode]) {
    self.currencyCodes = currencyCodes
  }

  func replaceAt(position: Int, newValue: CurrencyCode) {
    currencyCodes.updateValue(newValue, forKey: SelectedCurrencyPosition(value: position))
  }
}

extension SelectedCurrenciesStorageModel {

  public func toDomainModel() -> SelectedCurrencies {
    let maxFavoritePosition = currencyCodes.map(\.key.value).max() ?? 0
    let maxPosition = min(
      max(maxFavoritePosition, SelectedCurrencies.initial.currencyCodes.lastIndex),
      SelectedCurrencies.maxItems - 1
    )

    var nonSelectedInitials = SelectedCurrencies.initial.currencyCodes
      .filter { selectedCode in
        !currencyCodes.contains(where: { (_, code) in selectedCode == code })
      }
    let codes = (0...maxPosition).compactMap { i in
      currencyCodes[SelectedCurrencyPosition(value: i)] ?? nonSelectedInitials.removeFirstOrNil()
    }

    return SelectedCurrencies.of(
      currencyCodes: codes
    )
  }

  func toSwiftDataModel() -> SelectedCurrenciesSwiftDataModel {
    SelectedCurrenciesSwiftDataModel(
      currencyCodes: currencyCodes
    )
  }
}

extension SelectedCurrenciesSwiftDataModel {

  func toStorageModel() -> SelectedCurrenciesStorageModel {
    SelectedCurrenciesStorageModel(
      currencyCodes: currencyCodes
    )
  }
}
