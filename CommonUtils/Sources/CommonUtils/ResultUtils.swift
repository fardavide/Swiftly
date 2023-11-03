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
  
  /// Executes `f` in case of `Failure`
  /// - Parameter f: closure to execute
  /// - Returns: self
  @inlinable func onFailure(_ f: (Failure) async -> Void) async -> Result<Success, Failure> {
    switch self {
    case .success: break
    case let .failure(error): await f(error)
    }
    return self
  }
  
  /// Executes `f` in case of `Success`
  /// - Parameter f: closure to execute
  /// - Returns: self
  @inlinable func onSuccess(_ f: (Success) async -> Void) async -> Result<Success, Failure> {
    switch self {
    case let .success(value): await f(value)
    case .failure: break
    }
    return self
  }
  
  /// Return value of `Success` or `nil`
  /// - Returns: value of `Success` or `nil`
  @inlinable func orNil() -> Success? {
    switch self {
    case let .success(success): success
    case .failure: nil
    }
  }
  
  /// Handle `Failure` using `transform`, that will return a `Success` or a new `Failure`
  /// - Parameter transform: closure to handle `Failure`
  /// - Returns: `Result` of `Success` and `NewFailure`
  @inlinable func recover<NewFailure>(
    _ transform: (Failure) async -> Result<Success, NewFailure>
  ) async -> Result<Success, NewFailure> where NewFailure : Error {
    switch self {
    case let .success(success): .success(success)
    case let .failure(error): await transform(error)
    }
  }
  
  /// Handle `Failure` using `transform`, that will return a `Success` or a new `Failure`
  /// - Parameter transform: closure to handle `Failure`
  /// - Returns: `Result` of `Success` and `NewFailure`
  @inlinable func recover<NewFailure>(
    _ handle: @autoclosure () async -> Result<Success, NewFailure>
  ) async -> Result<Success, NewFailure> where NewFailure : Error {
    switch self {
    case let .success(success): .success(success)
    case .failure: await handle()
    }
  }
  
  /// async version of `flatMap`
  @inlinable func then<NewSuccess>(
    _ transform: (Success) async -> Result<NewSuccess, Failure>
  ) async -> Result<NewSuccess, Failure> {
    switch self {
    case let .success(success): await transform(success)
    case let .failure(error): .failure(error)
    }
  }
}
