//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import Foundation

public extension Result {
  
  /// Return value of `Success` or `defaultValue`
  /// - Parameter defaultValue: value to retuns if `.failure`
  /// - Returns: value of `Success` or `defaultValue`
  @inlinable func getOr(default defaultValue: Success) -> Success {
    orNil() ?? defaultValue
  }
  
  /// Return value of `Success` or result of `handle`
  /// - Parameter handle: closure that calculates the value to retuns if `.failure`
  /// - Returns: value of `Success` or result of `handle`
  @inlinable func getOr(handle: (Failure) -> Success) -> Success {
    switch self {
    case let .success(success): success
    case let .failure(failure): handle(failure)
    }
  }
  
  /// Return value of `Success` or `nil`
  /// - Returns: value of `Success` or `nil`
  @inlinable func orNil() -> Success? {
    switch self {
    case let .success(success): success
    case .failure: nil
    }
  }
  
  @inlinable func recover<NewFailure>(
    _ transform: (Failure) async -> Result<Success, NewFailure>
  ) async -> Result<Success, NewFailure> where NewFailure : Error {
    switch self {
    case let .success(success): .success(success)
    case let .failure(error): await transform(error)
    }
  }
  
  @inlinable func recover<NewFailure>(
    _ handle: @autoclosure () async -> Result<Success, NewFailure>
  ) async -> Result<Success, NewFailure> where NewFailure : Error {
    switch self {
    case let .success(success): .success(success)
    case .failure: await handle()
    }
  }
}
