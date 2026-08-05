import SFSafeSymbols
import SwiftlyUtils
import SwiftUI

/// What an error looks like on screen: one line of what happened, an optional line of detail, an icon.
public struct ErrorModel: Equatable {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  let image: SFSymbol

  public init(
    title: LocalizedStringKey,
    subtitle: LocalizedStringKey? = nil,
    image: SFSymbol
  ) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
  }

  func withMessage(message: LocalizedStringKey?) -> ErrorModel {
    ErrorModel(
      title: message ?? title,
      subtitle: message != nil ? title : nil,
      image: image
    )
  }
}

public extension DataError {

  /// Creates an `ErrorModel` for `ErrorView`
  ///
  /// Each case gets its own wording, because "something went wrong" is a dead end for everyone: the user
  /// cannot tell whether to turn on Wi-Fi, wait an hour or report a bug, and neither can the person reading
  /// the screenshot they send. Where the cause is the app's own fault — a build with no API key, a response
  /// we cannot read — the copy says so rather than blaming the network.
  ///
  /// - Parameter message: what the app was doing when this failed, e.g. "Cannot load rates". When given, it
  ///   becomes the headline and the explanation below moves to the subtitle.
  /// - Returns: `ErrorModel`
  func toErrorModel(message: LocalizedStringKey? = nil) -> ErrorModel {
    let baseModel = switch self {
    case let .network(cause): cause.toErrorModel()
    case let .storage(cause): cause.toErrorModel()
    case .unknown: ErrorModel(
      title: "Unknown error, please contact the developer",
      image: .exclamationmarkTriangle
    )
    }
    return baseModel.withMessage(message: message)
  }
}

private extension DataError.NetworkCause {

  func toErrorModel() -> ErrorModel {
    switch self {
    case .missingApiKey: ErrorModel(
      title: "This build has no API key, so rates cannot be downloaded",
      image: .lockSlash
    )
    case .invalidApiKey: ErrorModel(
      title: "The rates service rejected the app's API key, it may have expired",
      image: .lockTrianglebadgeExclamationmark
    )
    case .rateLimit: ErrorModel(
      title: "The app is over the rates service request limit, please try again later",
      image: .gaugeMedium
    )
    case .noConnection: ErrorModel(
      title: "No internet connection",
      image: .wifiSlash
    )
    case .timeout: ErrorModel(
      title: "The rates service took too long to answer",
      image: .clock
    )
    case .cancelled: ErrorModel(
      title: "The update was interrupted",
      image: .xmarkCircle
    )
    case let .server(statusCode): ErrorModel(
      title: "The rates service is having problems (error \(statusCode)), please try again later",
      image: .serverRack
    )
    case let .unexpectedResponse(statusCode): ErrorModel(
      title: "Unexpected answer from the rates service (error \(statusCode))",
      image: .network
    )
    // Unchanged wording: this string is the subtitle in the ErrorView snapshot baselines.
    case .json: ErrorModel(
      title: "Cannot process network response, please contact the developer",
      image: .exclamationmarkCircle
    )
    case .unknown: ErrorModel(
      title: "Unknown network error",
      image: .network
    )
    }
  }
}

private extension DataError.StorageCause {

  func toErrorModel() -> ErrorModel {
    switch self {
    case .noCache: ErrorModel(
      title: "Missing cached data, refresh from network is necessary",
      image: .externaldriveBadgeExclamationmark
    )
    case .readFailed: ErrorModel(
      title: "Cannot read the cached data, refresh from network is necessary",
      image: .externaldriveBadgeExclamationmark
    )
    case .unknown: ErrorModel(
      title: "Unknown cache error, contact the developer, in case refreshing from network won't fix this",
      image: .externaldriveTrianglebadgeExclamationmark
    )
    }
  }
}
