import CurrencyDomain
import NukeUI
import SwiftUI

/// `View` that displays the flag for a given `Currency`, in a given `Size`
public struct CurrencyFlagImage: View {
  
  private let currency: Currency
  private let size: Size
  
  public init(for currency: Currency, size: Size) {
    self.currency = currency
    self.size = size
  }
  
  public var body: some View {
    LazyImage(url: currency.flagUrl) { state in
      if let image = state.image {
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        Color
          .gray
          .opacity(0.2)
      }
    }
    .frame(width: size.width, height: size.height)
    .clipShape(.capsule)
  }
  
  public enum Size {
    case medium
    case small
    
    private static let ratio = 0.8
    
    var width: CGFloat {
      switch self {
      case .medium: 35
      case .small: 30
      }
    }
    
    var height: CGFloat {
      width * Size.ratio
    }
  }
}
