import Provider

private let currencyService: CurrencyService = .currencyApiDotCom

public final class CurrencyApiModule: Module {
  public init() {}

  public func register(on provider: Provider) {
    provider
      .register {
        switch currencyService {
        case .currencyApiDotCom: CurrencyApiDotComApi(endpoints: Endpoints(for: .currencyApiDotCom))
        case .exchangeRatesDotIo: fatalError("not implemented")
        } as any CurrencyApi
      }
  }
}
