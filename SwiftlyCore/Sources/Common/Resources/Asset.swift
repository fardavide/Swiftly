import SwiftlyUtils
import SwiftUI

public enum Asset {
  case gitHub
  case launchIcon
}

public extension Image {
  
  /// Creates an `Image` using app's assets
  init(asset: Asset) {
    self.init("\(asset)".capitalizedFirst)
  }
}
