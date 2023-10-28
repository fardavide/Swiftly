//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import Foundation
import SwiftData

public struct FetchDateStorageModel {
  public let date: Date
}

@Model
public class FetchDateSwitfDataModel {
  @Attribute(.unique) private let id = 0
  public var date: Date
  
  init(date: Date) {
    self.date = date
  }
}

public extension FetchDateStorageModel {
  static let distantPast = FetchDateStorageModel(date: Date.distantPast)
  
  func toSwiftDataModel() -> FetchDateSwitfDataModel {
    FetchDateSwitfDataModel(date: date)
  }
}

public extension FetchDateSwitfDataModel {
  static let distantPast = FetchDateSwitfDataModel(date: Date.distantPast)

  func toStorageModel() -> FetchDateStorageModel {
    FetchDateStorageModel(date: date)
  }
}
