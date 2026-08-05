import SwiftData
import SwiftlyUtils

/// Everything that can go wrong reading the on-device cache.
public enum StorageError: Error, Equatable, Sendable {

  /// The query ran, and there is nothing stored yet.
  ///
  /// Not a malfunction: it is what a first launch, or a launch after the store was reset, looks like.
  case noCache

  /// SwiftData refused the read.
  case readFailed

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
