public extension Array {
  
  @inlinable func mapWithIndices<R>(_ transform: (IndexedValue<Element>) -> R) -> [R] {
    withIndices().map(transform)
  }

  @discardableResult
  @inlinable mutating func removeFirstOrNil() -> Element? {
    isEmpty ? nil : removeFirst()
  }

  func withIndices() -> [IndexedValue<Element>] {
    indices.map { IndexedValue(index: $0, value: self[$0]) }
  }
}

public typealias IndexedValue<Value> = (index: Int, value: Value)
