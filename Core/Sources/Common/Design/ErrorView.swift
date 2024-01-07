import Resources
import SwiftlyUtils
import SwiftUI

public struct ErrorView: View {
  
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  let image: SfKey
  let retry: (() -> Void)?
  
  public init(
    title: LocalizedStringKey,
    subtitle: LocalizedStringKey? = nil,
    image: SfKey,
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
      SfSymbol(key: image)
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

public struct ErrorModel {
  let title: LocalizedStringKey
  let subtitle: LocalizedStringKey?
  let image: SfKey
  
  public init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, image: SfKey) {
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
  /// - Returns: `ErrorModel`
  func toErrorModel(message: LocalizedStringKey? = nil) -> ErrorModel {
    let baseModel = switch self {
    case let .network(cause):
      switch cause {
      case .json: ErrorModel(
        title: "Cannot process network response, please contact the developer",
        image: .exclamationmarkCircle
      )
      case .unknown: ErrorModel(
        title: "Unknown network error",
        image: .networkSlash
      )
      }
    case let .storage(cause):
      switch cause {
      case .noCache: ErrorModel(
        title: "Missing cached data, refresh from network is necessary",
        image: .externaldriveBadgeExclamationmark
      )
      case .unknown: ErrorModel(
        title: "Unknown cache error, contact the developer, in case refreshing from network won't fix this",
        image: .externaldriveTrianglebadgeExclamationmark
      )
      }
    case .unknown: ErrorModel(
      title: "Unknown error, please contact the developer",
      image: .exclamationmarkTriangle
    )
    }
    return baseModel.withMessage(message: message)
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
