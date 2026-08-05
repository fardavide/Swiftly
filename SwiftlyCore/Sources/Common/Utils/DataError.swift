/// The failure a repository reports to the layer above it.
///
/// `ApiError` and `StorageError` are each their own layer's vocabulary; this is the one that reaches
/// presentation, so every case has to be something a person can be shown — and, where possible, act on.
public enum DataError: Equatable, Error, Sendable {
  case network(cause: NetworkCause)
  case storage(cause: StorageCause)
  case unknown

  /// Why talking to a currency provider failed. Mirrors `ApiError` case for case.
  public enum NetworkCause: Equatable, Sendable {

    /// The build carries no API key, so the request was never made.
    case missingApiKey

    /// The provider rejected our key: unknown, revoked, or expired.
    case invalidApiKey

    /// The plan's quota or rate limit is spent.
    case rateLimit

    /// The provider could not be reached at all.
    case noConnection

    /// The provider took too long to answer.
    case timeout

    /// The request was cancelled — the screen went away, or a newer refresh replaced this one.
    case cancelled

    /// The provider failed on its own side.
    case server(statusCode: Int)

    /// The provider answered something we don't know how to read.
    case unexpectedResponse(statusCode: Int)

    /// The response body is not the model we decode it into.
    case json

    case unknown
  }

  /// Why reading from the on-device cache failed.
  public enum StorageCause: Equatable, Sendable {

    /// Nothing has been cached yet — the app has never completed a fetch.
    case noCache

    /// The cache is there but could not be read.
    case readFailed

    case unknown
  }
}

public extension DataError {

  /// Whether this failure is the app's own doing — the screen went away, or a newer refresh replaced this
  /// one — and so has nothing to report to the user.
  var isCancellation: Bool {
    self == .network(cause: .cancelled)
  }
}
