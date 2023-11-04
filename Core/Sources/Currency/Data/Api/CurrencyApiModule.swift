import Provider

public final class CurrencyApiModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealCurrencyApi() as CurrencyApi }
  }
}
