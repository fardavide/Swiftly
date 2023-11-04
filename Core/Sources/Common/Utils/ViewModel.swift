import Foundation

public protocol ViewModel<Action, State>: ObservableObject {
  associatedtype Action
  associatedtype State
  
  var state: State { get }
  func send(_ action: Action)
}

public extension ViewModel {
  
  func emit(block: @escaping () -> ()) {
    DispatchQueue.main.async(execute: block)
  }
}
