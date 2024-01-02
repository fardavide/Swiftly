/// Loading, Content, Error construct
public enum Lce<C, E: Error>: Equatable where C: Equatable, E: Equatable {
  case content(C)
  case error(E)
  case loading
}

/// Lce with GenericError
public typealias GenericLce<C: Equatable> = Lce<C, GenericError>

public extension Result where Success: Equatable {
  
  /// Map Result to Lce
  /// - Parameter error: closure that maps a Result's Failure to Lce's Error
  func toLce<E>(error: (Failure) -> E) -> Lce<Success, E> where E: Error, E: Equatable {
    switch self {
    case let .failure(e): Lce.error(error(e))
    case let .success(content): Lce.content(content)
    }
  }
  
  /// Maps Result to GenericLce
  func toLce() -> GenericLce<Success> {
    toLce(error: { _ in GenericError() })
  }
}

public extension Lce where E == GenericError {
  static var error: Lce {
    .error(GenericError())
  }
}
