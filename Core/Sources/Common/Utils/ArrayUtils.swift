public extension Array {
  
  /// - Returns: index of the last element
  var lastIndex: Int {
    endIndex - 1
  }
  
  /// Append element or move at last position if and element matching `comparingValue` is already pesent
  mutating func appendOrMoveToLast<T>(_ element: Element, comparingValue: (Element) -> T) where T: Equatable {
    let prevIndex = self.firstIndex(where: { comparingValue($0) == comparingValue(element) })
    if let prevIndex = prevIndex {
      remove(at: prevIndex)
    }
    append(element)
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

public extension Array where Element: Equatable {
  
  /// Append element or move at last position if already present
  mutating func appendOrMoveToLast(_ element: Element) {
    appendOrMoveToLast(element, comparingValue: { $0 })
  }
}

public typealias IndexedValue<Value> = (index: Int, value: Value)
