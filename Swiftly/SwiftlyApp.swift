import ConverterPresentation
import CurrencyApi
import CurrencyData
import Nuke
import Provider
import SwiftUI

private let provider = Provider.start()

@main
struct SwiftlyApp: App {

  init() {
    SwiftlyModule().start(with: provider)
    ImagePipeline.shared = ImagePipeline(configuration: .withURLCache)
  }

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ConverterView()
          .navigationTitle("Swiftly")
      }
    }
  }
}
