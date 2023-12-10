import Provider

private let currencyRateServiceType: CurrencyServiceType = .currencyApiDotCom

public final class CurrencyApiModule: Module {
  public init() {}

  public func register(on provider: Provider) {
    provider
      .register { [self] in
        RealCurrencyApi(
          currencyServce: currencyService(from: provider),
          currencyRateService: currencyRateService(from: provider)
        ) as CurrencyApi
      }
    
    // CurrencyApi.com
      .register { CurrencyApiComEndpoints(apiKey: ApiKey.currencyApiDotCom) }
      .register { CurrencyApiComCurrencyService(endpoints: provider.get()) }
      .register { CurrencyApiComCurrencyRateService(endpoints: provider.get()) }
    
    // ExchangeRates.io
      .register { ExchangeRatesIoEndpoints(apiKey: ApiKey.exchangeRatesDotIo) }
      .register { ExchangeRatesIoCurrencyRateService(endpoints: provider.get()) }
  }
  
  private func currencyService(from provider: Provider) -> CurrencyService {
    provider.get(CurrencyApiComCurrencyService.self)
  }
  
  private func currencyRateService(from provider: Provider) -> CurrencyRateService {
    switch currencyRateServiceType {
    case .currencyApiDotCom: provider.get(CurrencyApiComCurrencyRateService.self)
    case .exchangeRatesDotIo: provider.get(ExchangeRatesIoCurrencyRateService.self)
    }
  }
}
