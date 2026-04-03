import SwiftlyNetwork
import SwiftlyStorage
import SwiftlyUtils

@inlinable public func get<Data: Equatable>(
  shouldFetch: @escaping @autoclosure () -> Bool = true,
  fetch: @escaping @autoclosure () async -> Result<Data, ApiError>,
  readCache: @escaping @autoclosure () async -> Result<Data, StorageError>,
  saveCache: @escaping (Data) async -> Void
) async -> DataResult<Data> {
  switch shouldFetch() {
  case true:
    let fetchResult = await fetch().mapErrorToDataError()
    switch fetchResult {
    case let .success(data):
      await saveCache(data)
      return .success(data)
    case let .failure(fetchError):
      switch await readCache() {
      case let .success(data):
        return .successWithError(data: data, error: fetchError)
      case .failure:
        return .error(fetchError)
      }
    }
  case false:
    switch await readCache() {
    case let .success(data):
      return .success(data)
    case .failure:
      let fetchResult = await fetch().mapErrorToDataError()
      switch fetchResult {
      case let .success(data):
        await saveCache(data)
        return .success(data)
      case let .failure(error):
        return .error(error)
      }
    }
  }
}
