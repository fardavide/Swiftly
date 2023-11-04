import CurrencyApi
import CurrencyDomain
import CurrencyStorage
import Provider

public final class CurrencyDataModule: Module {
  public init() {}
  
  public var dependencies: [Module.Type] = [
    CurrencyApiModule.self,
    CurrencyStorageModule.self
  ]
  
  public func register(on provider: Provider) {
    provider
      .register {
        RealCurrencyRepository(
          api: provider.get(),
          getCurrentDate: provider.get(),
          storage: provider.get()
        ) as CurrencyRepository
      }
  }
}
