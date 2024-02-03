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
