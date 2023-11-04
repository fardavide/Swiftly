import DateUtils
import Provider

public final class CurrencyStorageModule: Module {
  public init() {}
  
  public var dependencies = [
    DateUtilsModule.self
  ]
  
  public func register(on provider: Provider) {
    provider
      .register { RealCurrencyStorage(container: provider.get()) as CurrencyStorage }
  }
}
