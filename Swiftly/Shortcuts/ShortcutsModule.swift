import CurrencyData
import Provider

final class ShortcutsModule: Module {
  
  var dependencies: [Module.Type] = [
    CurrencyDataModule.self
  ]
  
  public func register(on provider: Provider) {
    provider
      .register { CurrencyQuery() }
  }
}
