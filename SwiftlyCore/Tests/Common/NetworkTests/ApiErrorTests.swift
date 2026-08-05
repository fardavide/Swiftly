import Foundation
import Testing

import SwiftlyUtils
@testable import SwiftlyNetwork

/// `.serialized` because the stubbed `URLProtocol` answers from one static slot, which two tests running
/// at once would overwrite for each other.
@Suite("ApiErrorTests", .serialized)
struct ApiErrorTests {

  // MARK: - HTTP status classification

  @Test(arguments: [200, 201, 204, 299])
  func successfulStatusIsNotAnError(statusCode: Int) {
    #expect(ApiError(statusCode: statusCode) == nil)
  }

  @Test(arguments: [401, 403])
  func rejectedKeyIsUnauthorized(statusCode: Int) {
    #expect(ApiError(statusCode: statusCode)?.toDataError() == DataError.network(cause: .unauthorized))
  }

  @Test
  func missingEndpointIsNotFound() {
    #expect(ApiError(statusCode: 404)?.toDataError() == DataError.network(cause: .notFound))
  }

  @Test
  func exhaustedQuotaIsRateLimited() {
    #expect(ApiError(statusCode: 429)?.toDataError() == DataError.network(cause: .rateLimited))
  }

  @Test(arguments: [500, 502, 503])
  func serverFailureKeepsItsStatusCode(statusCode: Int) {
    let expected = DataError.network(cause: .server(statusCode: statusCode))
    #expect(ApiError(statusCode: statusCode)?.toDataError() == expected)
  }

  @Test
  func otherStatusIsUnexpected() {
    #expect(ApiError(statusCode: 418)?.toDataError() == DataError.network(cause: .unexpectedStatus(statusCode: 418)))
  }

  // MARK: - Transport failure classification

  @Test
  func unreachableNetworkIsNoConnection() {
    let codes: [URLError.Code] = [
      .notConnectedToInternet,
      .networkConnectionLost,
      .dataNotAllowed,
      .cannotFindHost,
      .dnsLookupFailed
    ]
    for code in codes {
      #expect(ApiError(requestFailure: URLError(code)).toDataError() == .network(cause: .noConnection))
    }
  }

  @Test
  func timedOutRequestIsTimeout() {
    #expect(ApiError(requestFailure: URLError(.timedOut)).toDataError() == .network(cause: .timeout))
  }

  @Test
  func unrecognisedFailureIsUnknown() {
    #expect(ApiError(requestFailure: URLError(.badURL)).toDataError() == .network(cause: .unknown))
    #expect(ApiError(requestFailure: SomeOtherError()).toDataError() == .network(cause: .unknown))
  }

  // MARK: - resultData

  /// The regression this whole taxonomy exists for: a rejected key answers 401 with an error envelope,
  /// which decodes into the expected payload no better than garbage would. Before the status was read,
  /// the app blamed the response format and told the user to contact the developer.
  @Test
  func rejectedKeyIsReportedAsUnauthorizedRatherThanBadJson() async {
    // given
    StubUrlProtocol.stub = .response(
      statusCode: 401,
      body: Data(#"{"message":"Invalid authentication credentials"}"#.utf8)
    )

    // when
    let result: Result<Payload, ApiError> = await stubbedSession().resultData(from: anyUrl)

    // then
    #expect(result.dataError == DataError.network(cause: .unauthorized))
  }

  @Test
  func malformedSuccessfulBodyIsReportedAsJson() async {
    // given
    StubUrlProtocol.stub = .response(statusCode: 200, body: Data(#"{"nope":true}"#.utf8))

    // when
    let result: Result<Payload, ApiError> = await stubbedSession().resultData(from: anyUrl)

    // then
    #expect(result.dataError == DataError.network(cause: .json))
  }

  @Test
  func transportFailureIsReportedWithItsCause() async {
    // given
    StubUrlProtocol.stub = .failure(URLError(.notConnectedToInternet))

    // when
    let result: Result<Payload, ApiError> = await stubbedSession().resultData(from: anyUrl)

    // then
    #expect(result.dataError == DataError.network(cause: .noConnection))
  }

  @Test
  func successfulBodyIsDecoded() async {
    // given
    StubUrlProtocol.stub = .response(statusCode: 200, body: Data(#"{"value":42}"#.utf8))

    // when
    let result: Result<Payload, ApiError> = await stubbedSession().resultData(from: anyUrl)

    // then
    #expect(result.dataError == nil)
    #expect(result.orNil() == Payload(value: 42))
  }
}

private let anyUrl = URL(string: "https://example.com/latest")!

private struct Payload: Decodable, Equatable {
  let value: Int
}

private struct SomeOtherError: Error {}

private func stubbedSession() -> URLSession {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [StubUrlProtocol.self]
  return URLSession(configuration: configuration)
}

private extension Result where Failure == ApiError {

  /// The failure as the type the rest of the app sees, or `nil` on success.
  ///
  /// `ApiError` can't be `Equatable` — `JsonError` carries a `DecodingError.Context` and a bare `Error` —
  /// so assertions go through the mapping instead, which is the value that reaches the UI anyway.
  var dataError: DataError? {
    switch self {
    case .success: nil
    case let .failure(error): error.toDataError()
    }
  }
}

/// Answers every request from a single stub, so `resultData` can be exercised without a network.
private final class StubUrlProtocol: URLProtocol {

  enum Stub {
    case response(statusCode: Int, body: Data)
    case failure(any Error)
  }

  /// `nonisolated(unsafe)` because `URLProtocol` is an Objective-C class instantiated by `URLSession` on
  /// its own queue: there is no way to hand it a stub other than a static one. The suite is `.serialized`
  /// so only one test writes it at a time.
  nonisolated(unsafe) static var stub: Stub = .failure(URLError(.unknown))

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    switch Self.stub {

    case let .response(statusCode, body):
      let response = HTTPURLResponse(
        url: request.url ?? anyUrl,
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: nil
      )
      if let response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      client?.urlProtocol(self, didLoad: body)
      client?.urlProtocolDidFinishLoading(self)

    case let .failure(error):
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}
