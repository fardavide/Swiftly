import Provider

final public class ConverterPresentionModule: Module {
  public init() {}

  public func register(on provider: Provider) {
    provider
      .register {
        ConverterViewModel(
          converterRepository: provider.get(),
          currencyRepository: provider.get()
        )
      }
  }
}
