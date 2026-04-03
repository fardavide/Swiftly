public enum DataResult<Data: Equatable>: Equatable {
  case success(Data)
  case successWithError(data: Data, error: DataError)
  case error(DataError)
}

public extension DataResult {

  var data: Data? {
    switch self {
    case let .success(data): data
    case let .successWithError(data, _): data
    case .error: nil
    }
  }

  var error: DataError? {
    switch self {
    case .success: nil
    case let .successWithError(_, error): error
    case let .error(error): error
    }
  }

  func fold<R>(
    withData: (Data, DataError?) -> R,
    withoutData: (DataError) -> R
  ) -> R {
    switch self {
    case let .success(data):
      withData(data, nil)
    case let .successWithError(data, error):
      withData(data, error)
    case let .error(error):
      withoutData(error)
    }
  }

  func map<NewData: Equatable>(
    _ transform: (Data) -> NewData
  ) -> DataResult<NewData> {
    switch self {
    case let .success(data):
      .success(transform(data))
    case let .successWithError(data, error):
      .successWithError(data: transform(data), error: error)
    case let .error(error):
      .error(error)
    }
  }

  func orThrow() -> Data {
    switch self {
    case let .success(data): data
    case let .successWithError(data, _): data
    case let .error(error): fatalError("\(error)")
    }
  }
}
