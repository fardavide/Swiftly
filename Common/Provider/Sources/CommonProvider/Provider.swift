final public class Provider {
  
  public static let instance = Provider()
  private var registry: [String: () -> Any] = [:]
  
  private init() {}
  
  public func register<T>(_ provider: @escaping () -> T) -> Provider {
    let key = "\(T.self)"
    registry[key] = provider
    return self
  }
  
  public func get<T>(_ type: T.Type) -> T {
    let key = "\(T.self)"
    if let provider = registry[key] {
      return provider() as! T
    }
    fatalError("key '\(key)' not registered")
  }
  
  public func get<T>() -> T {
    return get(T.self)
  }
}
