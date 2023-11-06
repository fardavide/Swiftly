import ConverterDomain
import ConverterStorage
import Provider

public final class ConverterDataModule: Module {
  public init() {}

  public var dependencies: [Module.Type] = [
    ConverterStorageModule.self
  ]

  public func register(on provider: Provider) {
    provider
      .register { RealConverterRepository(converterStorage: provider.get()) as ConverterRepository }
  }
}
