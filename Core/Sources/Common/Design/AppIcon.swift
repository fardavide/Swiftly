import SwiftUI

public extension Image {
  
  static var appIcon: Image {
    Bundle.main.iconFileName
      .flatMap { UIImage(named: $0) }
      .map { Image(uiImage: $0) }
    ?? Image(systemSymbol: .exclamationmarkTriangle)
  }
}

extension Bundle {
  var iconFileName: String? {
    guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
          let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
          let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
          let iconFileName = iconFiles.last
    else { return nil }
    return iconFileName
  }
}
