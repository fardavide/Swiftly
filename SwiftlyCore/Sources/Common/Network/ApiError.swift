import Foundation
import SwiftlyUtils

/// Everything that can go wrong between asking a currency provider for data and holding a decoded model.
///
/// Every case is a different thing to tell the user and — where there is one — a different thing for them
/// to do about it: `missingApiKey` and `invalidApiKey` need a new build, `rateLimit` and `serverError` need
/// patience, `noConnection` needs the user. `unknown` is the last resort, and it staying rare is what makes
/// the rest worth spelling out.
public enum ApiError: Error {

  /// The build carries no key for this provider, so no request was made.
  ///
  /// `ApiKey.swift` is committed with empty strings and rewritten from CI secrets at build time
  /// (`ci_scripts/ci_pre_xcodebuild.sh`), so a build made outside that pipeline has no key at all. The
  /// symptom — everything comes from cache and nothing ever refreshes — is otherwise indistinguishable
  /// from a dead network.
  case missingApiKey

  /// The provider rejected our key: unknown, revoked, or not entitled to the endpoint (`401`, `403`).
  case invalidApiKey

  /// The plan's quota or rate limit is spent (`429`).
  case rateLimit

  /// The provider could not be reached at all: no route, no DNS, connection dropped mid-flight.
  case noConnection

  /// The request was still waiting when it ran out of time (`URLError.timedOut`, or `408`).
  case timeout

  /// The request was cancelled — the screen went away, or a newer refresh replaced this one.
  case cancelled

  /// The provider failed on its own side (`5xx`).
  case serverError(statusCode: Int)

  /// A status outside `2xx` that none of the cases above claims.
  case unexpectedResponse(statusCode: Int)

  /// The response arrived, but its body is not the model we decode it into.
  case json(JsonError)

  /// Nothing above fits.
  case unknown
}

extension ApiError: Equatable {

  /// Hand written because `json`'s payload is not `Equatable`: `DecodingError.Context` and a bare
  /// `Any.Type`. Any two decoding failures compare equal, which is what a caller asserts on anyway — that
  /// the body didn't decode, never which key was missing.
  public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
    switch (lhs, rhs) {
    case (.missingApiKey, .missingApiKey),
      (.invalidApiKey, .invalidApiKey),
      (.rateLimit, .rateLimit),
      (.noConnection, .noConnection),
      (.timeout, .timeout),
      (.cancelled, .cancelled),
      (.json, .json),
      (.unknown, .unknown):
      true
    case let (.serverError(lhsCode), .serverError(rhsCode)):
      lhsCode == rhsCode
    case let (.unexpectedResponse(lhsCode), .unexpectedResponse(rhsCode)):
      lhsCode == rhsCode
    default:
      false
    }
  }
}

public extension ApiError {

  /// Classifies the HTTP status a provider answered with.
  ///
  /// `401` and `403` fold together on purpose: providers disagree about which one means "this key is not
  /// valid" and which means "this key is not entitled to this endpoint", and neither is something the app
  /// can do anything about.
  init(statusCode: Int) {
    let error: ApiError = switch statusCode {
    case 401, 403: .invalidApiKey
    case 408: .timeout
    case 429: .rateLimit
    case 500..<600: .serverError(statusCode: statusCode)
    default: .unexpectedResponse(statusCode: statusCode)
    }
    self = error
  }

  /// Classifies a `URLSession` transport failure.
  ///
  /// Everything that means "the request never reached the provider" collapses into `noConnection`: the
  /// difference between a missing route, a failed DNS lookup and a dropped connection is ours to log, not
  /// the user's to read.
  init(urlError: URLError) {
    let error: ApiError = switch urlError.code {
    case .notConnectedToInternet,
      .networkConnectionLost,
      .cannotConnectToHost,
      .cannotFindHost,
      .dnsLookupFailed,
      .dataNotAllowed,
      .internationalRoamingOff:
      .noConnection
    case .timedOut: .timeout
    case .cancelled: .cancelled
    default: .unknown
    }
    self = error
  }

  func toDataError() -> DataError {
    .network(cause: networkCause)
  }

  /// `DataError.NetworkCause` mirrors this type case for case: this one is the network layer's vocabulary,
  /// that one is what the rest of the app — which also has a storage layer to fail in — gets to see.
  private var networkCause: DataError.NetworkCause {
    switch self {
    case .missingApiKey: .missingApiKey
    case .invalidApiKey: .invalidApiKey
    case .rateLimit: .rateLimit
    case .noConnection: .noConnection
    case .timeout: .timeout
    case .cancelled: .cancelled
    case let .serverError(statusCode): .server(statusCode: statusCode)
    case let .unexpectedResponse(statusCode): .unexpectedResponse(statusCode: statusCode)
    case .json: .json
    case .unknown: .unknown
    }
  }
}

extension ApiError {

  /// Classifies a rejected response, letting the body override the status when the provider spelled the
  /// reason out there.
  static func from(statusCode: Int, body: Data) -> ApiError {
    ApiErrorPayload(body)?.toApiError() ?? ApiError(statusCode: statusCode)
  }

  /// Classifies a body that didn't decode into the model we asked for.
  ///
  /// Usually that really is a malformed response — but providers also answer `200 OK` with an error
  /// envelope where the rates should be, and "contact the developer" is the worst possible thing to tell
  /// someone whose key merely expired.
  static func from(jsonError: JsonError, body: Data) -> ApiError {
    ApiErrorPayload(body)?.toApiError() ?? .json(jsonError)
  }
}

public extension Result where Failure == ApiError {

  @inlinable func mapErrorToDataError() -> Result<Success, DataError> {
    mapError { apiError in apiError.toDataError() }
  }
}

public extension URLSession {

  /// Fetches `url` and decodes it, turning every way that can fail into an `ApiError`.
  ///
  /// The status is checked before the body is decoded, because a rejected request still answers with a
  /// well formed JSON body — just a different one — and letting the decoder see it first reports "we
  /// cannot read this response" for what is really an expired key.
  func resultData<T: Decodable>(from url: URL) async -> Result<T, ApiError> {
    do {
      let (data, response) = try await data(from: url)

      // A non-HTTP response cannot happen for these endpoints; treating it as a success keeps the
      // decoder — not this guard — in charge of saying what is wrong with the body.
      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
      guard (200..<300).contains(statusCode) else {
        return .failure(ApiError.from(statusCode: statusCode, body: data))
      }

      return JSONDecoder().resultDecode(T.self, from: data)
        .mapError { jsonError in ApiError.from(jsonError: jsonError, body: data) }

    } catch is CancellationError {
      return .failure(.cancelled)
    } catch let urlError as URLError {
      return .failure(ApiError(urlError: urlError))
    } catch {
      return .failure(.unknown)
    }
  }
}
