import CurrencyApi
import CurrencyData
import HomePresentation
import Nuke
import Provider
import SwiftUI

@main
struct SwiftlyApp: App {

  private let provider = Provider.start()
  
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
