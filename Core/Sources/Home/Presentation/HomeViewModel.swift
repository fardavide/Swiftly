import Foundation
import SwiftlyUtils

final class HomeViewModel: ViewModel {
  typealias Action = HomeAction
  typealias State = HomeState
  
  @Published var state: HomeState
  
  init(initialState: HomeState = .initial) {
    state = initialState
  }
  
  func send(_ action: HomeAction) {
    switch action {
    
    case .closeAbout:
      state.isAboutOpen = false
    
    case .openAbout:
      state.isAboutOpen = true
    }
  }
}
