import Provider

private let apiType: ApiType = .currencyApiDotCom

public final class CurrencyApiModule: Module {
  public init() {}

  public func register(on provider: Provider) {
    provider
      .register {
        switch apiType {
        case .currencyApiDotCom: CurrencyApiDotComApi()
        } as any CurrencyApi
      }
  }
}

private enum ApiType {
  case currencyApiDotCom
}
