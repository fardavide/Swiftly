import Design
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
        switch state {
        case .loading:
          ProgressView()
        case .error:
          Text("Cannot get app version")
        case let .content(aboutUiModel):
          ContentView(uiModel: aboutUiModel)
        }
      }
      .navigationTitle("About")
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
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

private struct ContentView: View {
  private let uiModel: AboutUiModel
  
  init(uiModel: AboutUiModel) {
    self.uiModel = uiModel
  }
  
  var body: some View {
    VStack {
      AppIcon()
        .resizable()
        .frame(width: 100, height: 100)
        .clipShape(.buttonBorder)
        .shadow(radius: 10)
        .padding(.bottom)
      Text(uiModel.appName)
        .font(.largeTitle)
        .bold()
      Text("Version \(uiModel.appVersion)")
    }
  }
}

#Preview("Success") {
  Provider.setupPreview(viewModel: AboutViewModel.samples.success)
  return AboutView(close: {}())
}

#Preview("Error") {
  Provider.setupPreview(viewModel: AboutViewModel.samples.versionError)
  return AboutView(close: {}())
}
