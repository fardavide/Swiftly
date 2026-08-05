import SFSafeSymbols
import SwiftlyUtils
import SwiftUI

public struct ErrorView: View {
  
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  let image: SFSymbol
  let retry: (() -> Void)?
  
  public init(
    title: LocalizedStringKey,
    subtitle: LocalizedStringKey? = nil,
    image: SFSymbol,
    retry: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
    self.retry = retry
  }
  
  public init(
    _ model: ErrorModel,
    retry: (() -> Void)? = nil
  ) {
    self.init(
      title: model.title,
      subtitle: model.subtitle,
      image: model.image,
      retry: retry
    )
  }
  
  public var body: some View {
    VStack {
      Image(systemSymbol: image)
        .font(.system(size: 80))
        .symbolEffect(.pulse)
        .foregroundStyle(.black, .red)
        .padding(.all, 20)
      
      Text(title)
        .font(.headline)
        .padding(.all, 10)

      if let subtitle = subtitle {
        Text(subtitle)
          .font(.footnote)
      }
      
      if let retry = retry {
        Button("Retry", action: retry)
          .padding()
      }
    }
    .padding()
    .multilineTextAlignment(.center)
  }
}

/// The copy a `DataError` is shown with.
///
/// `@unchecked Sendable` because it is an immutable bag of display values built from literals; neither
/// `LocalizedStringKey` nor `SFSymbol` promises a `Sendable` conformance we can rely on across SDK and
/// package versions, and the alternative is barring view state that holds one from crossing an actor.
public struct ErrorModel: Equatable, @unchecked Sendable {

  /// What went wrong, in the user's terms.
  public let title: LocalizedStringKey

  /// Extra detail, shown under the title.
  public let subtitle: LocalizedStringKey?

  /// The symbol standing in for the failure.
  public let image: SFSymbol

  public init(
    title: LocalizedStringKey,
    subtitle: LocalizedStringKey? = nil,
    image: SFSymbol
  ) {
    self.title = title
    self.subtitle = subtitle
    self.image = image
  }
  
  /// Puts the operation that failed on top, demoting the typed copy to the subtitle.
  ///
  /// A full-screen error reads best as "Cannot load rates" / "No internet connection": what the app was
  /// doing, then why it couldn't. Somewhere tighter — the refresh banner — the second line is the one
  /// worth the space, so callers there pass no message and use the model as it comes.
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
  /// - Returns: `ErrorModel`
  func toErrorModel(message: LocalizedStringKey? = nil) -> ErrorModel {
    let baseModel: ErrorModel = switch self {
    case let .network(cause): cause.errorModel
    case let .storage(cause): cause.errorModel
    case .unknown: ErrorModel(
      title: "Unknown error, please contact the developer",
      image: .exclamationmarkTriangle
    )
    }
    return baseModel.withMessage(message: message)
  }
}

private extension DataError.NetworkCause {

  var errorModel: ErrorModel {
    ErrorModel(title: title, image: image)
  }

  var title: LocalizedStringKey {
    switch self {
    case .json: "Cannot process network response, please contact the developer"
    case .noConnection: "No internet connection"
    case .notFound: "The currency service is no longer reachable, please update the app"
    case .rateLimited: "Too many requests, please try again later"
    case let .server(statusCode): "The currency service is unavailable (error \(statusCode))"
    case .timeout: "The currency service took too long to respond"
    case .unauthorized: "The currency service rejected the app's API key"
    case let .unexpectedStatus(statusCode): "Unexpected response from the currency service (error \(statusCode))"
    case .unknown: "Unknown network error"
    }
  }

  var image: SFSymbol {
    switch self {
    case .json: .exclamationmarkCircle
    case .noConnection: .wifiSlash
    case .notFound: .questionmarkCircle
    case .rateLimited: .hourglass
    case .server: .exclamationmarkTriangle
    case .timeout: .clock
    case .unauthorized: .lockSlash
    case .unexpectedStatus: .exclamationmarkCircle
    case .unknown: .network
    }
  }
}

private extension DataError.StorageCause {

  var errorModel: ErrorModel {
    ErrorModel(title: title, image: image)
  }

  var title: LocalizedStringKey {
    switch self {
    case .noCache: "Missing cached data, refresh from network is necessary"
    case .readFailed: "Cannot read the data saved on this device"
    case .unknown: "Unknown cache error, contact the developer, in case refreshing from network won't fix this"
    }
  }

  var image: SFSymbol {
    switch self {
    case .noCache: .externaldriveBadgeExclamationmark
    case .readFailed: .externaldriveTrianglebadgeExclamationmark
    case .unknown: .externaldriveTrianglebadgeExclamationmark
    }
  }
}

// For preview only
private extension ErrorView {
  init(
    _ error: DataError,
    message: LocalizedStringKey? = nil,
    retry: (() -> Void)? = nil
) {
    self.init(
      error.toErrorModel(message: message),
      retry: retry
    )
  }
}

#Preview("Network.json") {
  ErrorView(.network(cause: .json), message: "Can't fetch currencies") {}
}

#Preview("Network.noConnection") {
  ErrorView(.network(cause: .noConnection), message: "Can't fetch currencies") {}
}

#Preview("Network.unauthorized") {
  ErrorView(.network(cause: .unauthorized), message: "Can't fetch currencies") {}
}

#Preview("Network.rateLimited") {
  ErrorView(.network(cause: .rateLimited), message: "Can't fetch currencies") {}
}

#Preview("Network.server") {
  ErrorView(.network(cause: .server(statusCode: 503)), message: "Can't fetch currencies") {}
}

#Preview("Network.timeout") {
  ErrorView(.network(cause: .timeout), message: "Can't fetch currencies") {}
}

#Preview("Network.unknown") {
  ErrorView(.network(cause: .unknown), message: "Can't fetch currencies") {}
}

#Preview("Storage.noCache") {
  ErrorView(.storage(cause: .noCache), message: "Can't fetch currencies") {}
}

#Preview("Storage.unknown") {
  ErrorView(.storage(cause: .unknown), message: "Can't fetch currencies") {}
}

#Preview("Unknown") {
  ErrorView(.unknown, message: "Can't fetch currencies") {}
}
