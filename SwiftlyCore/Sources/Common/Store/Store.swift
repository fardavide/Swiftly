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
    let fetchResult = await fetch()
    switch fetchResult {
    case .success(let data):
      await saveCache(data)
      return .success(data)
    case .failure(let apiError):
      let cacheResult = await readCache()
      switch cacheResult {
      case .success(let cachedData):
        return .successWithError(data: cachedData, error: apiError.toDataError())
      case .failure:
        return .error(apiError.toDataError())
      }
    }
  case false:
    let cacheResult = await readCache()
    switch cacheResult {
    case .success(let cachedData):
      return .success(cachedData)
    case .failure:
      let fetchResult = await fetch()
      switch fetchResult {
      case .success(let data):
        await saveCache(data)
        return .success(data)
      case .failure(let apiError):
        return .error(apiError.toDataError())
      }
    }
  }
}
