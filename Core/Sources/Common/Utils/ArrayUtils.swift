public extension Array {
  
  @discardableResult
  @inlinable mutating func removeFirstOrNil() -> Element? {
    isEmpty ? nil : removeFirst()
  }
}
