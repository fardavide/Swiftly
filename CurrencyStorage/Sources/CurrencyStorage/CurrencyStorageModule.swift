import CommonDate
import CommonProvider

public final class CurrencyStorageModule: Module {
  public init() {}
  
  public var dependencies = [
    CommonDateModule.self
  ]
  
  public func register(on provider: Provider) {
    provider
      .register { RealCurrencyStorage() as CurrencyStorage }
  }
}
