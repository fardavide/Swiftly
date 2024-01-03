import Provider
import SwiftUI

public struct AboutView: View {
  @StateObject var viewModel: AboutViewModel  = getProvider().get()
  private let close: () -> Void
  
  public init(close: @escaping @autoclosure () -> Void) {
    self.close = close
  }
  
  public var body: some View {
    let state = viewModel.state
    NavigationStack {
      VStack {
        switch state.appVersion {
        case .loading:
          ProgressView()
        case .error:
          Text("Cannot get app version")
        case let .content(appVersion):
          Text("Version \(appVersion)")
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") {
            close()
          }
        }
      }
    }
  }
}

#Preview("Error") {
  Provider.setupPreview(viewModel: AboutViewModel.samples.error)
  return AboutView(close: {}())
}

#Preview("Success") {
  Provider.setupPreview(viewModel: AboutViewModel.samples.success)
  return AboutView(close: {}())
}
