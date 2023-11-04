public protocol Printable {}

public extension Printable {
  
  @discardableResult
  func print(
    enabled: Bool = true,
    message: (Self) -> String = { "\($0)" }
  ) -> Self {
    if enabled {
      Swift.print(message(self))
    }
    return self
  }
}

extension Result: Printable {}
extension String: Printable {}
