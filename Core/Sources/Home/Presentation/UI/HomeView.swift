import AboutPresentation
import ConverterPresentation
import Provider
import Resources
import SwiftUI

public struct HomeView: View {
  @StateObject var viewModel: HomeViewModel = getProvider().get()
  
  public init() {}
  
  public var body: some View {
    NavigationStack {
      ConverterView()
        .navigationTitle("Swiftly")
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button {
              viewModel.send(.openAbout)
            } label: {
              Image(systemName: image(.infoCircle))
            }
          }
        }
        .sheet(isPresented: $viewModel.state.isAboutOpen) {
          AboutView(close: viewModel.send(.closeAbout))
        }
    }
  }
}

#Preview {
  getProvider()
    .register { AboutViewModel.samples.success }
    .register { ConverterViewModel.samples.success }
    .register { HomeViewModel() }
  return HomeView()
}
