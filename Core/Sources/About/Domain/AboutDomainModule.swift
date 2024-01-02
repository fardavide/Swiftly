import Provider

public final class AboutDomainModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider.register { RealGetAppVersion() as GetAppVersion }
  }
}
