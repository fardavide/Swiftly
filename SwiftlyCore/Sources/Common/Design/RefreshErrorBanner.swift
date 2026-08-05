import SFSafeSymbols
import SwiftlyUtils
import SwiftUI

/// The strip shown over the content when a refresh failed but there is still cached data to work with.
///
/// Deliberately not an `ErrorView`: the screen underneath is usable — the rates are just old — so this
/// states what went wrong in a line and offers a retry, instead of taking the screen over. It says *what*
/// failed rather than only *that* something did, because "refresh failed" leaves the reader with no idea
/// whether to turn on Wi-Fi, wait, or report a bug.
public struct RefreshErrorBanner: View {

  private let model: ErrorModel
  private let retry: (() -> Void)?

  public init(
    _ model: ErrorModel,
    retry: (() -> Void)? = nil
  ) {
    self.model = model
    self.retry = retry
  }

  public var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemSymbol: model.image)
        .imageScale(.large)

      VStack(alignment: .leading, spacing: 2) {
        Text(model.title)
          .font(.footnote.weight(.semibold))
        Text("Showing cached data")
          .font(.caption2)
          .opacity(0.9)
      }

      Spacer(minLength: 0)

      if let retry = retry {
        Button("Retry", action: retry)
          .font(.footnote.weight(.semibold))
          .tint(.white)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.red.opacity(0.9))
    .foregroundStyle(.white)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}

// For preview only
private extension RefreshErrorBanner {
  init(
    _ error: DataError,
    retry: (() -> Void)? = nil
  ) {
    self.init(
      error.toErrorModel(),
      retry: retry
    )
  }
}

#Preview("Network.noConnection") {
  RefreshErrorBanner(.network(cause: .noConnection)) {}
}

#Preview("Network.invalidApiKey") {
  RefreshErrorBanner(.network(cause: .invalidApiKey)) {}
}

#Preview("Network.rateLimit") {
  RefreshErrorBanner(.network(cause: .rateLimit))
}
