import Foundation
import SwiftlyUtils

/// A failed remote call, classified as precisely as the transport allows.
///
/// Everything used to arrive here as `.unknown` or — worse — as `.jsonError`, because an API that
/// refuses the key answers with an error envelope, and an error envelope decodes into the expected
/// payload no better than a truncated body would. Reading the status before decoding is what turns
/// "Cannot process network response" into "The currency service rejected the app's API key".
public enum ApiError: Error {

  /// The response body isn't the JSON the call expects.
  case jsonError(JsonError)

  /// The device couldn't reach the server.
  case noConnection

  /// The endpoint isn't there any more: HTTP 404.
  case notFound

  /// The API key's quota is exhausted: HTTP 429.
  case rateLimited

  /// The API failed on its own side: HTTP 5xx.
  case serverError(statusCode: Int)

  /// The request didn't complete in time.
  case timeout

  /// The API refused the key: HTTP 401 or 403.
  case unauthorized

  /// A non-successful status without a more specific case.
  case unexpectedStatus(statusCode: Int)

  /// Anything that couldn't be classified.
  case unknown
}

public extension ApiError {

  /// Classifies an HTTP status code.
  /// - Returns: `nil` when `statusCode` is a success, so callers can bind the failure with `if let`.
  init?(statusCode: Int) {
    switch statusCode {
    case 200..<300: return nil
    case 401, 403: self = .unauthorized
    case 404: self = .notFound
    case 429: self = .rateLimited
    case 500..<600: self = .serverError(statusCode: statusCode)
    default: self = .unexpectedStatus(statusCode: statusCode)
    }
  }

  /// Classifies the error `URLSession` throws when a request never produces a response.
  ///
  /// A failed DNS lookup or an unreachable host is reported as `.noConnection` alongside the outright
  /// "no network" codes: from where the user sits they are the same problem, and the same sentence —
  /// check your connection — is the useful thing to say.
  init(requestFailure error: any Error) {
    guard let code = (error as? URLError)?.code else {
      self = .unknown
      return
    }
    switch code {
    case .notConnectedToInternet,
         .networkConnectionLost,
         .dataNotAllowed,
         .internationalRoamingOff,
         .cannotConnectToHost,
         .cannotFindHost,
         .dnsLookupFailed:
      self = .noConnection
    case .timedOut:
      self = .timeout
    default:
      self = .unknown
    }
  }

  func toDataError() -> DataError {
    let cause: DataError.NetworkCause = switch self {
    case .jsonError: .json
    case .noConnection: .noConnection
    case .notFound: .notFound
    case .rateLimited: .rateLimited
    case let .serverError(statusCode): .server(statusCode: statusCode)
    case .timeout: .timeout
    case .unauthorized: .unauthorized
    case let .unexpectedStatus(statusCode): .unexpectedStatus(statusCode: statusCode)
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

  /// Performs a GET and decodes its body, mapping every failure mode onto an `ApiError`.
  ///
  /// The status code is inspected *before* decoding: a non-2xx body is an error envelope, not a
  /// payload, and letting it reach the decoder would report every rejected key and every exhausted
  /// quota as a malformed response.
  func resultData<T: Decodable>(from url: URL) async -> Result<T, ApiError> {
    do {
      let (data, response) = try await data(from: url)
      if let statusCode = (response as? HTTPURLResponse)?.statusCode,
         let error = ApiError(statusCode: statusCode) {
        return .failure(error)
      }
      return JSONDecoder().resultDecode(T.self, from: data)
        .mapError { .jsonError($0) }
    } catch {
      return .failure(ApiError(requestFailure: error))
    }
  }
}
