import Foundation
import SwiftlyUtils

public enum ApiError: Error {
  case jsonError(JsonError)
  case unknown
}

public extension ApiError {
  func toDataError() -> DataError {
    let cause: DataError.NetworkCause = switch self {
    case .jsonError: .json
    case .unknown: .unknown
    }
    return .network(cause: cause)
  }
}

public extension Result where Failure == ApiError {
  
  @inlinable func mapErrorToDataError() -> Result<Success, DataError> {
    mapError { apiError in apiError.toDataError() }
  }
}

public extension URLSession {

  func resultData<T: Decodable>(from url: URL) async -> Result<T, ApiError> {
    do {
      let (data, _) = try await data(from: url)
      return JSONDecoder().resultDecode(T.self, from: data)
        .mapError { .jsonError($0) }
    } catch {
      return .failure(.unknown)
    }
  }
}
