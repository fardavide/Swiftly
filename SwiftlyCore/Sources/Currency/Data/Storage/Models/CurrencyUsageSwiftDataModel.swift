import SwiftData

@Model
public class CurrencyUsageSwiftDataModel {
  var currencyCode: String
  var count: Int
  
  public init(currencyCode: String, usageCount: Int) {
    self.currencyCode = currencyCode
    self.count = usageCount
  }
}

extension CurrencyUsageSwiftDataModel: Comparable {
  public static func < (lhs: CurrencyUsageSwiftDataModel, rhs: CurrencyUsageSwiftDataModel) -> Bool {
    lhs.count < rhs.count
  }
}
