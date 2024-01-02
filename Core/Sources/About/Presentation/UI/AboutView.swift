import Provider
import SwiftUI

public struct AboutView: View {  
  @StateObject var viewModel: AboutViewModel  = getProvider().get()
  
  public init() {}
  
  public var body: some View {
    VStack {
      
    }
  }
}

#Preview {
  AboutView()
}
