import ConverterDomain
import CurrencyDomain
import SwiftData
import SwiftlyUtils

public struct SelectedCurrenciesStorageModel {
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
    let maxFavoritePosition = currencyCodes.max(by: { c1, c2 in c1.key > c2.key })?.key.value ?? 0
    let maxPosition = max(maxFavoritePosition, SelectedCurrencies.initial.currencyCodes.endIndex)

    var nonSelectedInitials = SelectedCurrencies.initial.currencyCodes
      .filter { selectedCode in
        !currencyCodes.contains(where: { (_, code) in selectedCode == code })
      }
    var dict = [Int: CurrencyCode]()
    for i in 0...maxPosition {
      let code = currencyCodes[SelectedCurrencyPosition(value: i)] ?? nonSelectedInitials.removeFirstOrNil()
      if let c = code {
        dict[i] = c
      }
    }

    return SelectedCurrencies.of(
      currencyCodes: dict.sorted { e1, e2 in e1.key < e2.key }.map(\.value)
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
