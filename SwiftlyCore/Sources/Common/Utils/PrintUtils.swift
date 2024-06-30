public protocol Printable {}

public extension Printable {

  @discardableResult
  func print(
    enabled: Bool = true,
    message: (Self) -> Any = { "\($0)" }
  ) -> Self {
    if verbose || enabled {
      Swift.print(message(self))
    }
    return self
  }
}

private let verbose = false

extension Array: Printable {}
extension Result: Printable {}
extension String: Printable {}
