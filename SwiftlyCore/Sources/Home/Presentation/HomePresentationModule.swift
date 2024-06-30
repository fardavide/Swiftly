import AboutPresentation
import ConverterPresentation
import Provider

public final class HomePresentationModule: Module {
  public init() {}
  
  public var dependencies: [Module.Type] = [
    AboutPresentationModule.self,
    ConverterPresentionModule.self
  ]
  
  public func register(on provider: Provider) {
    provider.register { HomeViewModel() }
  }
}
