import Provider
import ConverterPresentation
import CurrencyApi
import CurrencyData
import SwiftUI

private let provider = Provider.start()

@main
struct SwiftlyApp: App {
  
  init() {
    SwiftlyModule().start(with: provider)
  }
  
  var body: some Scene {
    WindowGroup {
      ConverterView()
    }
  }
}
