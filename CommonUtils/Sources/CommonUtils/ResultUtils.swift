//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import Foundation

public extension Result {
  
  /*
   Return value of `Success` or `defaultValue`
   */
  func getOr(default defaultValue: Success) -> Success {
    switch self {
    case let .success(success):
      return success
    case .failure:
      return defaultValue
    }
  }
  
  /*
   Return value of `Success` or result of `handle`
   */
  func getOr(handle: (Failure) -> Success) -> Success {
    switch self {
    case let .success(success):
      return success
    case let .failure(failure):
      return handle(failure)
    }
  }
}
