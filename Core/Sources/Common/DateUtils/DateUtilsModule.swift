import Provider

public final class DateUtilsModule: Module {
  public init() {}

  public func register(on provider: Provider) {
    provider
      .register { RealGetCurrentDate() as GetCurrentDate }
  }
}
