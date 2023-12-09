final public class Provider {

  private var registry: [String: () -> Any]

  init(registry: [String: () -> Any]) {
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
      // swiftlint:disable force_cast
      return .success(provider() as! T)
      // swiftlint:enable force_cast
    } else {
      return .failure(ProviderError(key: key))
    }
  }

  public func get<T>(_ type: T.Type) -> T {
    let result = safeGet(type)
    switch result {
    case let .success(success): return success
    case let .failure(error): fatalError("key '\(error.key)' not registered. Registered types: \(registry.keys)")
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
  Provider.get()
}

public extension Provider {
  private static var instance: Provider?

  static func get() -> Provider {
    instance ?? start()
  }

  static func start(registry: [String: () -> Any] = [:]) -> Provider {
    if instance == nil {
      instance = Provider(registry: registry)
      return instance!
    } else {
      fatalError("Provider already initialized")
    }
  }

  static func setupPreview<ViewModel>(viewModel: @escaping @autoclosure () -> ViewModel) {
    let provider = start()
    provider.register(viewModel)
  }
}

extension Provider {

  static func test(registry: [String: () -> Any] = [:]) -> Provider {
    instance = Provider(registry: registry)
    return instance!
  }
}
