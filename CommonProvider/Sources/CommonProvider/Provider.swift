import CommonUtils

final public class Provider {
  
  private var registry: [String: () -> Any]
  
  public init(
    registry: [String : () -> Any] = [:]
  ) {
    self.registry = registry
  }
  
  @discardableResult
  public func register<T>(_ provider: @escaping () -> T) -> Provider {
    let key = "\(T.self)"
    registry[key] = provider
    return self
  }
  
  public func safeGet<T>(_ type: T.Type) -> Result<T, ProviderError> {
    let key = "\(T.self)"
    if let provider = registry[key] {
      return .success(provider() as! T)
    } else {
      return .failure(ProviderError(key: key))
    }
  }
  
  public func get<T>(_ type: T.Type) -> T {
    safeGet(type).getOr { error in
      fatalError("key '\(error.key)' not registered")
    }
  }
  
  public func get<T>() -> T {
    return get(T.self)
  }
}

public struct ProviderError: Error, Equatable {
  let key: String
}
