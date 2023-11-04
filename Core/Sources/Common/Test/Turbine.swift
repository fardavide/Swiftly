import Combine
import XCTest

extension XCTestCase {
  
  public func test<Value: Equatable>(
    _ publisher: any Publisher<Value, Never>,
    block: @escaping (any Turbine<Value>) async -> ()
  ) async {
    let turbine = RealTurbine<Value>(
      publisher: publisher
        .eraseToAnyPublisher()
        .removeDuplicates()
        .eraseToAnyPublisher()
    )
    
    await block(turbine)
    
    turbine.complete()
  }
}

public protocol Turbine<Value> {
  associatedtype Value
  
  func value() async -> Value
  func expectInitial(value: Value) async
}

class RealTurbine<Value : Equatable>: Turbine {
  
  private let timeout: TimeInterval = 5
  private let interval: TimeInterval = 0.2
  private let subject = CurrentValueSubject<TurbineValue<Value>, Never>(.notReady)
  private var cancellables: [AnyCancellable] = []
  
  init(publisher: AnyPublisher<Value, Never>) {
    publisher.removeDuplicates()
      .sink { value in self.subject.value = .ready(value) }
      .store(in: &cancellables)
  }
  
  func value() async -> Value {
    let value = switch subject.value {
    case .notReady: await awaitFirst()
    case let .ready(ready): ready
    }
    subject.value = .notReady
    return value
  }
  
  func expectInitial(value: Value) async {
    switch subject.value {
    case .notReady:
      let v = await awaitFirst()
      if v == value {
        await expectInitial(value: v)
      }
      subject.value = .notReady
    case let .ready(v):
      if v == value {
        await expectInitial(value: v)
      }
    }
  }
  
  func complete() {
    subject.send(completion: .finished)
    for cancellable in cancellables {
      cancellable.cancel()
    }
  }
  
  private func awaitFirst() async -> Value {
    await withUnsafeContinuation { continuation in
      var cancellable: AnyCancellable?
      
      cancellable = subject.print().first()
        .sink { result in
          switch result {
          case .finished:
            break
          case let .failure(error):
            fatalError(error.localizedDescription)
          }
          cancellable?.cancel()
        } receiveValue: { value in
          switch value {
          case .notReady: break
          case let .ready(value): continuation.resume(with: .success(value))
          }
        }
    }
  }
}

enum TurbineValue<V> {
  case notReady
  case ready(_ value: V)
}
