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
  /// `Sendable` because values cross from the caller of these requirements into the main-actor-isolated
  /// implementation; without the constraint the compiler rejects that hop for `any Turbine`. `test()`
  /// already demands it of every value type.
  associatedtype Value: Sendable

  /// The oldest unconsumed emission, suspending until one arrives if none is buffered.
  func value() async -> Value

  /// Consumes the first emission when it equals `value`; otherwise puts it back for the next `value()` call.
  ///
  /// A `@Published` publisher replays the current state on subscribe, so what arrives first depends on
  /// timing: subscribe before the view model's startup work lands and it is the initial state; subscribe
  /// after and the initial state was never seen, only the progressed one. Both orders are legitimate, which
  /// is why a mismatch is put back rather than reported as a failure.
  func expectInitial(value: Value) async
}

/// Buffers every emission into an `AsyncStream` and hands them out oldest-first, so waiting for the next
/// value is a genuine suspension.
///
/// The previous implementation kept only the latest emission and, when `expectInitial` saw the expected
/// value, recursed on unchanged state until something new arrived. That recursion has no suspension point,
/// so it never yields its cooperative-pool thread and allocates async frames without bound. On a many-core
/// dev machine the view model's next emission lands in milliseconds and the spin goes unnoticed; on a small
/// CI runner a handful of tests spinning together occupy the whole pool, the work that would produce those
/// emissions can never run, and the process starves until it dies — taking every suite's results with it.
///
/// `@MainActor` rather than `@unchecked Sendable`: every touchpoint already lives there — the publisher is
/// subscribed and emits on the main actor, and the test body consuming the turbine runs on it too. Single
/// consumer by contract, matching the sequential test bodies: two concurrent `value()` calls would race on
/// the iterator.
@MainActor
final class RealTurbine<Value: Equatable & Sendable>: Turbine {

  private var iterator: AsyncStream<Value>.Iterator
  private let continuation: AsyncStream<Value>.Continuation
  private var pushedBack: Value?
  private var cancellables: [AnyCancellable] = []

  init(publisher: AnyPublisher<Value, Never>) {
    let (stream, continuation) = AsyncStream.makeStream(of: Value.self)
    iterator = stream.makeAsyncIterator()
    self.continuation = continuation
    publisher
      .removeDuplicates()
      .sink { continuation.yield($0) }
      .store(in: &cancellables)
  }

  func value() async -> Value {
    await next()
  }

  func expectInitial(value: Value) async {
    let first = await next()
    if first != value {
      pushedBack = first
    }
  }

  func complete() {
    continuation.finish()
    for cancellable in cancellables {
      cancellable.cancel()
    }
  }

  private func next() async -> Value {
    if let pushedBack {
      self.pushedBack = nil
      return pushedBack
    }
    // A `mutating async` call on an isolated stored property is rejected — the exclusive access would
    // span the suspension — so advance a local copy; the iterator struct is only a handle to the
    // stream's shared storage, and the write-back keeps the stored handle current. The advance goes
    // through `next(isolation:)` because the plain `next()` is nonisolated and calling it would send
    // this non-Sendable, main-actor-region iterator across an isolation boundary; passing the current
    // isolation keeps the whole step on the main actor.
    var iterator = self.iterator
    guard let value = await iterator.next(isolation: #isolation) else {
      fatalError("Turbine completed while a test was still awaiting a value")
    }
    self.iterator = iterator
    return value
  }
}
