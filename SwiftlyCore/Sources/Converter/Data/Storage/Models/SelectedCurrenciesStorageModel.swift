import ConverterDomain
import CurrencyDomain
import SwiftData
import SwiftlyUtils

public struct SelectedCurrenciesStorageModel {
  
  public let currencyCodes: [SelectedCurrencyPosition: CurrencyCode]
  
  public init(currencyCodes: [SelectedCurrencyPosition: CurrencyCode]) {
    self.currencyCodes = currencyCodes
  }
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
    SelectedCurrencies.of(
      currencyCodes: currencyCodes
        .sorted(by: { a, b in a.key.value < b.key.value })
        .map(\.value)
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
