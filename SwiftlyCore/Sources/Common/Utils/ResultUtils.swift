import Foundation

public extension Result where Failure == GenericError {
  
  /// Initializes a `Result` with an optional success value.
  ///
  /// This initializer allows for the creation of a `Result` object from an optional value.
  /// If the provided value is non-nil, the `Result` is a success, containing the value.
  /// If the value is nil, the `Result` is a failure, containing a `GenericError`.
  ///
  /// - Parameter value: An optional value of the generic `Success` type.
  ///
  /// Usage:
  /// ```
  /// let optionalData: Data? = fetchData()
  /// ```
  init(_ value: Success?) {
    self = value != nil ? .success(value!) : .failure(GenericError())
  }
}

public extension Result {
  
  /// Executes `f` in case of `Failure`
  /// - Parameter f: closure to execute
  /// - Returns: self
  @discardableResult @inlinable func onFailure(_ f: (Failure) async -> Void) async -> Result<Success, Failure> {
    switch self {
    case .success: break
    case let .failure(error): await f(error)
    }
    return self
  }
  
  /// Executes `f` in case of `Success`
  /// - Parameter f: closure to execute
  /// - Returns: self
  @discardableResult @inlinable func onSuccess(_ f: (Success) async -> Void) async -> Result<Success, Failure> {
    switch self {
    case let .success(value): await f(value)
    case .failure: break
    }
    return self
  }
  
  /// Return value of `Success` or `defaultValue`
  /// - Parameter defaultValue: value to retuns if `.failure`
  /// - Returns: value of `Success` or `defaultValue`
  @inlinable func or(default defaultValue: Success) -> Success {
    orNil() ?? defaultValue
  }
  
  /// Return value of `Success` or result of `handle`
  /// - Parameter handle: closure that calculates the value to retuns if `.failure`
  /// - Returns: value of `Success` or result of `handle`
  @inlinable func or(handle: (Failure) -> Success) -> Success {
    switch self {
    case let .success(success): success
    case let .failure(failure): handle(failure)
    }
  }
  
  /// Return `Result` of `Success` and `NewFailure` replacing `Failure` with the given `NewFailure`
  /// - Parameter error: the error to be used instead of the original one
  /// - Returns: `Result` of `Success` and `NewFailure`
  @inlinable func or<NewFailure>(_ error: NewFailure) -> Result<Success, NewFailure> {
    mapError { _ in error }
  }
  
  /// Return value of `Success` or `nil`
  /// - Returns: value of `Success` or `nil`
  @inlinable func orNil() -> Success? {
    switch self {
    case let .success(success): success
    case .failure: nil
    }
  }
  
  /// Return value of `Success` or throw `Failure`
  /// - Returns: value of `Success` or throw `Failure`
  func orThrow() -> Success {
    or { error in fatalError("\(error)") }
  }
  
  /// Handle `Failure` using `transform`, that will return a `Success` or a new `Failure`
  /// - Parameter transform: closure to handle `Failure`
  /// - Returns: `Result` of `Success` and `NewFailure`
  @inlinable func recover<NewFailure>(
    _ transform: (Failure) async -> Result<Success, NewFailure>
  ) async -> Result<Success, NewFailure> where NewFailure: Error {
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
  ) async -> Result<Success, NewFailure> where NewFailure: Error {
    switch self {
    case let .success(success): .success(success)
    case .failure: await handle()
    }
  }
  
  /// Returns `Failure` or throw fatal error
  /// - Returns: `Failure` or throw fatal error
  func requireFailure() -> Failure {
    switch self {
    case .success: fatalError("Expected Failure, but got Success")
    case let .failure(error): error
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
