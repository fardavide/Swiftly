import CommonDate
import CommonProvider

public final class ConverterStorageModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealConverterStorage() as ConverterStorage }
  }
}
