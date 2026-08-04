import Combine
import Foundation

/// `@MainActor` because `ViewModel` is: reading a view model's `$state` publisher and driving its actions
/// both happen on the main actor, and `Published.Publisher` is not `Sendable`, so the whole helper has to
/// stay on that actor rather than hand the publisher across an isolation boundary.
@MainActor
public func test<Value: Equatable & Sendable>(
  _ publisher: any Publisher<Value, Never>,
  block: @escaping @MainActor (any Turbine<Value>) async -> Void
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

/// `Sendable` so a turbine can be awaited from the `@MainActor` test body without the compiler treating
/// each `await` as sending it across an isolation boundary.
public protocol Turbine<Value>: Sendable {
  associatedtype Value

  func value() async -> Value
  func expectInitial(value: Value) async
}

/// `@unchecked` because the compiler cannot see that the only mutable state is a `CurrentValueSubject`
/// (safe to send and read concurrently) and a `cancellables` array written once, during `init`.
final class RealTurbine<Value: Equatable & Sendable>: Turbine, @unchecked Sendable {

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

      // Unwrap to `.ready` values *before* `first()`. `subject` replays its current value on subscribe, and
      // `awaitFirst` is only reached when that value is `.notReady` — so a bare `first()` delivers `.notReady`,
      // takes the `break`, and completes without ever resuming the continuation. The awaiting task then stays
      // suspended forever: the assertions still pass, but the process can never exit.
      cancellable = subject
        .compactMap { value -> Value? in
          switch value {
          case .notReady: nil
          case let .ready(value): value
          }
        }
        .first()
        .sink { _ in
          cancellable?.cancel()
        } receiveValue: { value in
          continuation.resume(returning: value)
        }
    }
  }
}

enum TurbineValue<V> {
  case notReady
  case ready(_ value: V)
}
