import Provider

public final class AboutDomainModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealBundleInfo() as BundleInfo }
      .register { RealGetAppName(bundleInfo: provider.get()) as GetAppName }
      .register { RealGetAppVersion(bundleInfo: provider.get()) as GetAppVersion }
  }
}
