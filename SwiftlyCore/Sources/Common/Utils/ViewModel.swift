import Foundation

@MainActor
public protocol ViewModel<Action, State>: ObservableObject {
  associatedtype Action
  associatedtype State

  var state: State { get }
  func send(_ action: Action) async
}

public extension ViewModel {

  func send(_ action: Action) {
    Task { await self.send(action) }
  }

  func emit(block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
  }
}
