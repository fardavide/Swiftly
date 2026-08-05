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

#Preview("Network.missingApiKey") {
  ErrorView(.network(cause: .missingApiKey), message: "Can't fetch currencies") {}
}

#Preview("Network.invalidApiKey") {
  ErrorView(.network(cause: .invalidApiKey), message: "Can't fetch currencies") {}
}

#Preview("Network.rateLimit") {
  ErrorView(.network(cause: .rateLimit), message: "Can't fetch currencies") {}
}

#Preview("Network.noConnection") {
  ErrorView(.network(cause: .noConnection), message: "Can't fetch currencies") {}
}

#Preview("Network.server") {
  ErrorView(.network(cause: .server(statusCode: 503)), message: "Can't fetch currencies") {}
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
