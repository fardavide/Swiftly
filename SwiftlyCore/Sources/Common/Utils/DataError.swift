/// A failure surfaced by the data layer, typed down to a reason the user can act on.
///
/// The taxonomy exists for the sake of the message that ends up on screen: "No internet connection",
/// "The currency service rejected the app's API key" and "Too many requests" call for three different
/// reactions, and collapsing them into one catch-all leaves the user with nothing to do but retry
/// forever. Every case here maps to its own copy in `ErrorModel`.
public enum DataError: Equatable, Error {
  case network(cause: NetworkCause)
  case storage(cause: StorageCause)
  case unknown

  /// Why a fetch from the remote source failed.
  public enum NetworkCause: Equatable {

    /// The response body isn't the JSON the call expects — the API changed its contract, or answered
    /// with something that isn't a payload at all.
    case json

    /// The device couldn't reach the server: airplane mode, no Wi-Fi or cellular, a failed DNS lookup,
    /// or a connection dropped mid-request.
    case noConnection

    /// The endpoint isn't there any more: HTTP 404.
    case notFound

    /// The API key's quota is exhausted: HTTP 429.
    case rateLimited

    /// The API failed on its own side: HTTP 5xx.
    case server(statusCode: Int)

    /// The request didn't complete in time.
    case timeout

    /// The API refused the key: HTTP 401 or 403. Missing, wrong, expired, or a plan that doesn't cover
    /// the endpoint.
    case unauthorized

    /// A non-successful status without a more specific case.
    case unexpectedStatus(statusCode: Int)

    /// Anything that couldn't be classified.
    case unknown
  }

  /// Why a read from the local cache failed.
  public enum StorageCause: Equatable {

    /// Nothing has been cached yet, so there is nothing to fall back on.
    case noCache

    /// The cache is there but couldn't be read.
    case readFailed

    /// Anything that couldn't be classified.
    case unknown
  }
}
