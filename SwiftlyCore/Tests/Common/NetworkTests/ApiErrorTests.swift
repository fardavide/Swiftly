import Testing

import Foundation
import SwiftlyUtils
@testable import SwiftlyNetwork

@Suite("ApiErrorTests")
struct ApiErrorTests {

  // MARK: - HTTP status
  @Test
  func unauthorizedIsAnInvalidKey() {
    #expect(ApiError(statusCode: 401) == .invalidApiKey)
  }

  @Test
  func forbiddenIsAnInvalidKey() {
    #expect(ApiError(statusCode: 403) == .invalidApiKey)
  }

  @Test
  func tooManyRequestsIsARateLimit() {
    #expect(ApiError(statusCode: 429) == .rateLimit)
  }

  @Test
  func requestTimeoutIsATimeout() {
    #expect(ApiError(statusCode: 408) == .timeout)
  }

  @Test
  func fiveHundredsAreServerErrors() {
    #expect(ApiError(statusCode: 500) == .serverError(statusCode: 500))
    #expect(ApiError(statusCode: 503) == .serverError(statusCode: 503))
  }

  @Test
  func anyOtherStatusIsUnexpected() {
    #expect(ApiError(statusCode: 404) == .unexpectedResponse(statusCode: 404))
    #expect(ApiError(statusCode: 422) == .unexpectedResponse(statusCode: 422))
  }

  // MARK: - transport
  @Test
  func offlineIsNoConnection() {
    #expect(ApiError(urlError: URLError(.notConnectedToInternet)) == .noConnection)
  }

  @Test
  func unreachableHostIsNoConnection() {
    #expect(ApiError(urlError: URLError(.cannotFindHost)) == .noConnection)
    #expect(ApiError(urlError: URLError(.dnsLookupFailed)) == .noConnection)
    #expect(ApiError(urlError: URLError(.networkConnectionLost)) == .noConnection)
  }

  @Test
  func timedOutIsATimeout() {
    #expect(ApiError(urlError: URLError(.timedOut)) == .timeout)
  }

  @Test
  func cancelledIsCancelled() {
    #expect(ApiError(urlError: URLError(.cancelled)) == .cancelled)
  }

  @Test
  func anyOtherTransportFailureIsUnknown() {
    #expect(ApiError(urlError: URLError(.badServerResponse)) == .unknown)
  }

  // MARK: - error body
  @Test
  func aRejectedRequestPrefersTheReasonInItsBody() {
    let body = Data(#"{"message": "No API key found in request"}"#.utf8)

    #expect(ApiError.from(statusCode: 400, body: body) == .invalidApiKey)
  }

  @Test
  func aRejectedRequestFallsBackToItsStatus() {
    #expect(ApiError.from(statusCode: 503, body: Data()) == .serverError(statusCode: 503))
  }

  /// The failure this whole type exists for: providers that answer `200 OK` and put the refusal in the body
  /// used to surface as "cannot process network response, contact the developer".
  @Test
  func anUndecodableBodyThatDescribesAFailureIsNotADecodingError() {
    let body = Data(#"{"success": false, "error": {"code": 101, "type": "invalid_access_key"}}"#.utf8)
    let jsonError = JsonError.unknown(GenericError())

    #expect(ApiError.from(jsonError: jsonError, body: body) == .invalidApiKey)
  }

  @Test
  func anUndecodableBodyThatDescribesNothingStaysADecodingError() {
    let body = Data(#"{"data": {"EUR": {"code": "EUR"}}}"#.utf8)
    let jsonError = JsonError.unknown(GenericError())

    #expect(ApiError.from(jsonError: jsonError, body: body) == .json(jsonError))
  }

  // MARK: - DataError mapping
  @Test
  func everyCaseMapsToItsOwnNetworkCause() {
    #expect(ApiError.missingApiKey.toDataError() == .network(cause: .missingApiKey))
    #expect(ApiError.invalidApiKey.toDataError() == .network(cause: .invalidApiKey))
    #expect(ApiError.rateLimit.toDataError() == .network(cause: .rateLimit))
    #expect(ApiError.noConnection.toDataError() == .network(cause: .noConnection))
    #expect(ApiError.timeout.toDataError() == .network(cause: .timeout))
    #expect(ApiError.cancelled.toDataError() == .network(cause: .cancelled))
    #expect(ApiError.serverError(statusCode: 500).toDataError() == .network(cause: .server(statusCode: 500)))
    #expect(ApiError.json(.unknown(GenericError())).toDataError() == .network(cause: .json))
    #expect(ApiError.unknown.toDataError() == .network(cause: .unknown))
  }

  @Test
  func anUnexpectedStatusKeepsItsCode() {
    let dataError = ApiError.unexpectedResponse(statusCode: 418).toDataError()

    #expect(dataError == .network(cause: .unexpectedResponse(statusCode: 418)))
  }
}
