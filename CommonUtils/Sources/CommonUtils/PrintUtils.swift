public protocol Printable {}

public extension Printable {
  
  @discardableResult
  func print(
    message: (Self) -> String = { "\($0)" }
  ) -> Self {
    Swift.print(message(self))
    return self
  }
}

extension Result: Printable {}
