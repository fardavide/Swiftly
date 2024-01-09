#if canImport(UIKit)
import UIKit
#endif

public extension UIApplication {
  func closeKeyboard() {
#if canImport(UIKit)
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
  }
}
