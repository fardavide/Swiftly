import Testing

import Foundation
@testable import SwiftlyNetwork

@Suite("ApiErrorPayloadTests")
struct ApiErrorPayloadTests {

  // MARK: - currencyapi.com
  @Test
  func currencyApiComRejectedKey() throws {
    let payload = try #require(ApiErrorPayload(Data(#"{"message": "No API key found in request"}"#.utf8)))

    #expect(payload.message == "No API key found in request")
    #expect(payload.toApiError() == .invalidApiKey)
  }

  // MARK: - currencybeacon.com
  @Test
  func currencyBeaconComRejectedKey() throws {
    let body = """
      {
        "meta": { "code": 401, "error_type": "invalid_auth", "error_detail": "Invalid API key" },
        "response": []
      }
      """

    let payload = try #require(ApiErrorPayload(Data(body.utf8)))

    #expect(payload.statusCode == 401)
    #expect(payload.reason == "invalid_auth")
    #expect(payload.toApiError() == .invalidApiKey)
  }

  /// currencybeacon.com wraps every answer in `meta`, successes included, so `meta` alone must not read as
  /// a failure — otherwise a response shape we cannot decode would be reported as a rejected key.
  @Test
  func currencyBeaconComSuccessIsNotAnError() {
    let body = """
      {
        "meta": { "code": 200, "disclaimer": "…" },
        "response": { "date": "2024-01-01", "base": "USD", "rates": { "EUR": 0.9 } }
      }
      """

    #expect(ApiErrorPayload(Data(body.utf8)) == nil)
  }

  // MARK: - exchangeratesapi.io
  @Test
  func exchangeRatesIoRejectedKeyWithNumericCode() throws {
    let body = #"{"success": false, "error": {"code": 101, "type": "invalid_access_key", "info": "…"}}"#

    let payload = try #require(ApiErrorPayload(Data(body.utf8)))

    #expect(payload.statusCode == 101)
    #expect(payload.reason == "invalid_access_key")
    #expect(payload.toApiError() == .invalidApiKey)
  }

  @Test
  func exchangeRatesIoRejectedKeyWithStringCode() throws {
    let body = #"{"error": {"code": "invalid_access_key", "message": "Access key is invalid"}}"#

    let payload = try #require(ApiErrorPayload(Data(body.utf8)))

    #expect(payload.reason == "invalid_access_key")
    #expect(payload.message == "Access key is invalid")
    #expect(payload.toApiError() == .invalidApiKey)
  }

  // MARK: - classification
  /// A spent quota is routinely phrased as something the key did, so the quota wording has to win over the
  /// key wording — answering "your key is invalid" would send someone off to replace a working key.
  @Test
  func aSpentQuotaIsARateLimitEvenWhenItBlamesTheKey() throws {
    let body = #"{"message": "Your API key has exceeded its monthly request limit"}"#

    let payload = try #require(ApiErrorPayload(Data(body.utf8)))

    #expect(payload.toApiError() == .rateLimit)
  }

  @Test
  func aClaimedStatusIsUsedWhenTheWordingSaysNothing() throws {
    let body = #"{"meta": {"code": 503, "error_detail": "Try again"}}"#

    let payload = try #require(ApiErrorPayload(Data(body.utf8)))

    #expect(payload.toApiError() == .serverError(statusCode: 503))
  }

  // MARK: - non-envelopes
  @Test
  func aBodyThatIsNotJsonIsNotAnEnvelope() {
    #expect(ApiErrorPayload(Data("<html>502 Bad Gateway</html>".utf8)) == nil)
  }

  @Test
  func anEmptyBodyIsNotAnEnvelope() {
    #expect(ApiErrorPayload(Data()) == nil)
  }

  @Test
  func aRegularPayloadIsNotAnEnvelope() {
    let body = #"{"data": {"EUR": {"code": "EUR", "name": "Euro", "symbol": "€"}}}"#

    #expect(ApiErrorPayload(Data(body.utf8)) == nil)
  }
}
