import Resources
import SwiftUI

/// Creates an `Image` using the `SfKey`
/// - Returns: `Image`
public func SfSymbol(key: SfKey) -> Image {
  Image(systemName: image(key))
}

#Preview {
  SfSymbol(key: .keyboardChevronCompactDown)
}
