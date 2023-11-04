import AppStorage
import Provider

public final class AppStorageModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealAppStorage.instance as AppStorage }
      .register { RealAppStorage.instance.container }
  }
}
