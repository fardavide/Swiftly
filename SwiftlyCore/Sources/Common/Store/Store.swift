import Network
import SwiftlyStorage
import SwiftlyUtils

@inlinable public func get<Data>(
  shouldFetch: @escaping @autoclosure () -> Bool = true,
  fetch: @escaping @autoclosure () async -> Result<Data, ApiError>,
  readCache: @escaping @autoclosure () async -> Result<Data, StorageError>,
  saveCache: @escaping (Data) async -> Void
) async -> Result<Data, DataError> {
  switch shouldFetch() {
  case true:
    await fetch()
      .mapErrorToDataError()
      .onSuccess(saveCache)
      .recover { apiError in
        await readCache()
          .or(apiError)
      }
  case false:
    await readCache()
      .mapErrorToDataError()
      .recover(
        await fetch()
          .mapErrorToDataError()
          .onSuccess(saveCache)
      )
  }
}
