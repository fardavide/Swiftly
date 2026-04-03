/// A result type that distinguishes between fresh data, recovered cached data (with a fetch error), and pure errors.
///
/// Similar to `Result`, but with a third case for when data is available from cache despite a fetch failure.
/// This prevents silently swallowing errors when falling back to cached data.
///
/// Usage:
/// ```
/// switch dataResult {
/// case .success(let data):
///   showData(data)
/// case .successWithError(let data, let error):
///   showData(data)
///   showBanner(error)
/// case .error(let error):
///   showError(error)
/// }
/// ```
public enum DataResult<Data: Equatable>: Equatable {
  case success(Data)
  case successWithError(data: Data, error: DataError)
  case error(DataError)
}

public extension DataResult {

  /// Non-nil when data is available (`success` or `successWithError`)
  var data: Data? {
    switch self {
    case .success(let data): data
    case .successWithError(let data, _): data
    case .error: nil
    }
  }

  /// Non-nil when an error occurred (`error` or `successWithError`)
  var error: DataError? {
    switch self {
    case .success: nil
    case .successWithError(_, let error): error
    case .error(let error): error
    }
  }

  /// Fold over the two meaningful branches:
  /// - `withData`: called for `success` and `successWithError` (error is nil for `success`)
  /// - `withoutData`: called for `error`
  func fold<R>(
    withData: (Data, DataError?) -> R,
    withoutData: (DataError) -> R
  ) -> R {
    switch self {
    case .success(let data):
      withData(data, nil)
    case .successWithError(let data, let error):
      withData(data, error)
    case .error(let error):
      withoutData(error)
    }
  }

  /// Return data or throw fatal error
  func orThrow() -> Data {
    guard let data else { fatalError("\(error!)") }
    return data
  }

  /// Map the success data, preserving the error state
  func map<NewData>(_ transform: (Data) -> NewData) -> DataResult<NewData> {
    switch self {
    case .success(let data): .success(transform(data))
    case .successWithError(let data, let error): .successWithError(data: transform(data), error: error)
    case .error(let error): .error(error)
    }
  }
}
