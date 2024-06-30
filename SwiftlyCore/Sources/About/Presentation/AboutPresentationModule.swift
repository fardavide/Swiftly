import AboutDomain
import Provider

public final class AboutPresentationModule: Module {
  public init() {}
  
  public var dependencies: [Module.Type] = [
    AboutDomainModule.self
  ]
  
  public func register(on provider: Provider) {
    provider.register {
      AboutViewModel(
        getAppName: provider.get(),
        getAppVersion: provider.get()
      )
    }
  }
}
