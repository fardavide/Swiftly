final public class Provider {
  
  private var registry: [String: () -> Any]
  
  init(registry: [String : () -> Any]) {
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
    let result = safeGet(type)
    switch result {
    case let .success(success): return success
    case let .failure(error): fatalError("key '\(error.key)' not registered")
    }
  }
  
  public func get<T>() -> T {
    get(T.self)
  }
}

public struct ProviderError: Error, Equatable {
  let key: String
}

public func getProvider() -> Provider {
  Provider.require()
}

public extension Provider {
  private static var instance: Provider?

  static func require() -> Provider {
    if let safeInstance = instance {
      safeInstance
    } else {
      fatalError("Provider not initialized")
    }
  }
  
  static func start(registry: [String : () -> Any] = [:]) -> Provider {
    if instance == nil {
      instance = Provider(registry: registry)
      return instance!
    } else {
      fatalError("Provider already initialized")
    }
  }
}

extension Provider {
  
  static func test(registry: [String : () -> Any] = [:]) -> Provider {
    instance = Provider(registry: registry)
    return instance!
  }
}
