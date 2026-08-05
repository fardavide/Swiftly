import Foundation

/// The error envelope a currency provider puts in the response body.
///
/// Three providers, three shapes, and none of them reliably paired with a matching HTTP status.
/// exchangeratesapi.io in particular answers `200 OK` with the failure in the body, which reaches the
/// decoder as a plain "this isn't the model I expected" and reads to the user as "the app is broken" when
/// the truth is "the key expired". So before trusting either the status or the decoder, we look for the
/// handful of keys these providers actually use:
///
/// * currencyapi.com — `{ "message": "No API key found in request" }`
/// * currencybeacon.com — `{ "meta": { "code": 401, "error_type": "invalid_auth", "error_detail": "…" } }`
/// * exchangeratesapi.io — `{ "success": false, "error": { "code": 101, "type": "invalid_access_key" } }`
///
/// Read with `JSONSerialization` rather than `Decodable`: the shapes disagree on nesting *and* on whether
/// `code` is a number or a string, and probing a dictionary is honest about that, where a `Codable` model
/// would be three `init(from:)` special cases pretending to be one type.
struct ApiErrorPayload: Equatable {

  /// The status the body claims, when it carries one.
  let statusCode: Int?

  /// The machine readable reason, e.g. `invalid_access_key`.
  let reason: String?

  /// The human readable reason, when the provider sends one.
  let message: String?

  /// Reads `body` as an error envelope, or fails when it doesn't look like one.
  ///
  /// A body that describes success is not an envelope — currencybeacon.com wraps *every* answer in `meta`,
  /// including the good ones — and reading one out of it would turn a provider changing its response shape
  /// into a phantom "invalid key".
  init?(_ body: Data) {
    guard let root = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any] else {
      return nil
    }
    self.init(root: root)
    guard describesFailure else {
      return nil
    }
  }

  private init(root: [String: Any]) {
    if let meta = root["meta"] as? [String: Any] {
      statusCode = meta["code"] as? Int
      reason = meta["error_type"] as? String
      message = meta["error_detail"] as? String

    } else if let error = root["error"] as? [String: Any] {
      statusCode = error["code"] as? Int
      reason = error["type"] as? String ?? error["code"] as? String
      message = error["info"] as? String ?? error["message"] as? String

    } else {
      statusCode = root["status"] as? Int
      reason = root["error"] as? String
      message = root["message"] as? String
    }
  }
}

extension ApiErrorPayload {

  /// Turns the envelope into a typed error, or nothing when it says nothing we can act on.
  ///
  /// Quota is checked before the key, because a spent quota is routinely reported as something the *key*
  /// did — "your API key has exceeded its monthly requests" — and answering "get a new key" to that sends
  /// the reader off to fix something that isn't broken.
  ///
  /// Matching is by substring: the exact spelling differs per provider (`invalid_access_key`,
  /// `invalid_auth`, `usage_limit_reached`) and a wording we haven't seen should still land in the right
  /// bucket rather than in `unknown`.
  func toApiError() -> ApiError? {
    let text = [reason, message]
      .compactMap { $0 }
      .joined(separator: " ")
      .lowercased()

    if text.contains("limit") || text.contains("quota") {
      return .rateLimit
    }
    if text.contains("key") || text.contains("auth") || text.contains("subscription") {
      return .invalidApiKey
    }
    if let statusCode {
      return ApiError(statusCode: statusCode)
    }
    return nil
  }

  /// Whether this envelope describes a failure at all.
  ///
  /// A `2xx` in the body is the provider saying the call went fine, whatever else the body carries, so it
  /// vetoes the rest: without this, currencybeacon.com's `meta.code: 200` would make every success we
  /// cannot parse look like an error.
  private var describesFailure: Bool {
    if let statusCode, (200..<300).contains(statusCode) {
      return false
    }
    return statusCode != nil || reason != nil || message != nil
  }
}
