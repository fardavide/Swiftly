//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 29/10/23.
//

import Foundation

public protocol GetCurrentDate {
  func run() -> Date
}

public class FakeGetCurrentDate: GetCurrentDate {
  private let date: Date
  
  public init(date: Date) {
    self.date = date
  }
  
  public func run() -> Date {
    date
  }
}

final class RealGetCurrentDate: GetCurrentDate {
  func run() -> Date {
    Date.now
  }
}
