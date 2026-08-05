import SwiftData
import SwiftlyUtils

/// A failed read from the local cache.
public enum StorageError: Error {

  /// Nothing has been cached yet, so there is nothing to fall back on.
  case noCache

  /// The store is there but refused the read.
  case readFailed

  /// Anything that couldn't be classified.
  case unknown
}

public extension StorageError {
  func toDataError() -> DataError {
    let cause: DataError.StorageCause = switch self {
    case .noCache: .noCache
    case .readFailed: .readFailed
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
  
  func fetchAll<T>(_ descriptor: FetchDescriptor<T>) -> Result<[T], StorageError> where T: PersistentModel {
    do {
      return try .success(fetch(descriptor))
    } catch {
      return .failure(.readFailed)
    }
  }
  
  func fetchOne<T>(_ descriptor: FetchDescriptor<T>) -> Result<T, StorageError> where T: PersistentModel {
    var finalDescriptor = descriptor
    finalDescriptor.fetchLimit = 1
    return fetchAll(finalDescriptor).flatMap { array in
      if let item = array.first {
        .success(item)
      } else {
        .failure(.noCache)
      }
    }
  }
}
