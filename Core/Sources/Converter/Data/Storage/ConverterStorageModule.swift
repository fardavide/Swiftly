import Provider

public final class ConverterStorageModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealConverterStorage(container: provider.get()) as ConverterStorage }
  }
}
