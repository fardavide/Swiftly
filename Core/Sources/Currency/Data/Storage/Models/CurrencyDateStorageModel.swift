import Foundation
import SwiftData

public struct CurrencyDateStorageModel {
  public let updatedAt: Date
}

@Model
public class CurrencyDateSwiftDataModel {
  @Attribute(.unique) public let id = 0
  var updatedAt: Date
  
  init(updatedAt: Date) {
    self.updatedAt = updatedAt
  }
}

public extension Date {
  func toCurrencyDateStorageModel() -> CurrencyDateStorageModel {
    CurrencyDateStorageModel(updatedAt: self)
  }
}

extension CurrencyDateStorageModel {
  public static let distantPast = CurrencyDateStorageModel(updatedAt: Date.distantPast)
  
  func toSwiftDataModel() -> CurrencyDateSwiftDataModel {
    CurrencyDateSwiftDataModel(updatedAt: updatedAt)
  }
}

extension CurrencyDateSwiftDataModel {
  static let distantPast = CurrencyDateSwiftDataModel(updatedAt: Date.distantPast)
  
  func toStorageModel() -> CurrencyDateStorageModel {
    CurrencyDateStorageModel(updatedAt: updatedAt)
  }
}
