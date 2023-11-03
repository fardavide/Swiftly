import CommonUtils
import SwiftData

public enum StorageError: Error {
  case noCache
  case unknown
}

public extension StorageError {
  func toDataError() -> DataError {
    .storage
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
