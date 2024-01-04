import CurrencyApi
import CurrencyData
import HomePresentation
import Nuke
import Provider
import Resources
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
      HomeView()
    }
  }
}
