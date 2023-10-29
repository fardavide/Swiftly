//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 29/10/23.
//

import Foundation

public extension Date {
  
  static func +(lhs: Date, rhs: Duration) -> Date {
    let initialInterval = lhs.timeIntervalSince1970
    let finalInterval = initialInterval + rhs.secondsInterval
    return Date(timeIntervalSince1970: finalInterval)
  }
  
  static func -(lhs: Date, rhs: Duration) -> Date {
    let initialInterval = lhs.timeIntervalSince1970
    let finalInterval = initialInterval - rhs.secondsInterval
    return Date(timeIntervalSince1970: finalInterval)
  }
  
  static func %(lhs: Date, rhs: Date) -> Duration {
    let interval = rhs.distance(to: lhs)
    let fixedInterval = lhs > rhs ? abs(interval) : -abs(interval)
    return fixedInterval.seconds()
  }
}
