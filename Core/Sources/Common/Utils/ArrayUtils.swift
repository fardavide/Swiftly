public extension Array {
  
  /// - Returns: index of the last element
  var lastIndex: Int {
    endIndex - 1
  }
  
  @inlinable func mapWithIndices<R>(_ transform: (IndexedValue<Element>) -> R) -> [R] {
    withIndices().map(transform)
  }

  /// Mutate the array to remove the first element
  /// - Returns: the first element, or `nil` if the array is empty
  @discardableResult @inlinable mutating func removeFirstOrNil() -> Element? {
    isEmpty ? nil : removeFirst()
  }
  
  /// - Returns: new Subsequence containing at most `count` elements
  func take(_ count: Int) -> [Element].SubSequence {
    self[0...Swift.min(count, lastIndex)]
  }

  func withIndices() -> [IndexedValue<Element>] {
    indices.map { IndexedValue(index: $0, value: self[$0]) }
  }
}

public typealias IndexedValue<Value> = (index: Int, value: Value)
