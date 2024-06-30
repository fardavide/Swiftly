import Foundation

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
  
  /// Maps an array to a new array including the index of each element.
  /// - Returns: An array of the transformed values.
  @inlinable func mapWithIndices<R>(_ transform: (IndexedValue<Element>) -> R) -> [R] {
    withIndices().map(transform)
  }

  /// Mutate the array to remove the first element
  /// - Returns: the first element, or `nil` if the array is empty
  @discardableResult @inlinable mutating func removeFirstOrNil() -> Element? {
    isEmpty ? nil : removeFirst()
  }
  
  /// Sorts an array according to the provided sort descriptors.
  /// - Parameter descriptors: An array of `SortDescriptor` to sort the array.
  /// - Returns: A sorted array based on the given descriptors.
  func sorted(using descriptors: [SortDescriptor<Element>]) -> [Element] {
    sorted { valueA, valueB in
      for descriptor in descriptors {
        let result = descriptor.comparator(valueA, valueB)
        
        switch result {
        case .orderedSame:
          // Keep iterating if the two elements are equal,
          // since that'll let the next descriptor determine
          // the sort order:
          break
        case .orderedAscending:
          return true
        case .orderedDescending:
          return false
        }
      }
      
      // If no descriptor was able to determine the sort
      // order, we'll default to false (similar to when
      // using the '<' operator with the built-in API):
      return false
    }
  }
  
  /// - Returns: new Subsequence containing at most `count` elements
  func take(_ count: Int) -> [Element].SubSequence {
    self[0...Swift.min(count, lastIndex)]
  }

  /// Wraps each element in an `IndexedValue` containing its index.
  /// - Returns: An array of `IndexedValue` elements.
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

public struct SortDescriptor<Value> {
  let comparator: (Value, Value) -> ComparisonResult
}

public extension SortDescriptor {
  static func keyPath<T: Comparable>(
    _ keyPath: KeyPath<Value, T>,
    order: SortOrder = .forward
  ) -> Self {
    Self { rootA, rootB in
      let valueA = rootA[keyPath: keyPath]
      let valueB = rootB[keyPath: keyPath]
      
      guard valueA != valueB else {
        return .orderedSame
      }
      
      return switch order {
      case .forward: valueA < valueB ? .orderedAscending : .orderedDescending
      case .reverse: valueA > valueB ? .orderedAscending : .orderedDescending
      }
    }
  }
}
