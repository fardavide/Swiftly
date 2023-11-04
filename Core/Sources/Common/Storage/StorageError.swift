import SwiftData
import SwiftlyUtils

public enum StorageError: Error {
  case noCache
  case unknown
}

public extension StorageError {
  func toDataError() -> DataError {
    let cause: DataError.StorageCause = switch self {
    case .noCache: .noCache
    case .unknown: .unknown
    }
    return .storage(cause: cause)
  }
}

public extension Result where Failure == StorageError {
  
  @inlinable func mapErrorToDataError() -> Result<Success, DataError> {
    mapError { storageError in storageError.toDataError() }
  }
}

public extension ModelContext {
  func resultFetch<T>(_ descriptor: FetchDescriptor<T>) -> Result<[T], StorageError> where T : PersistentModel {
    do {
      return try .success(fetch(descriptor))
    } catch {
      return .failure(.unknown)
    }
  }
}
