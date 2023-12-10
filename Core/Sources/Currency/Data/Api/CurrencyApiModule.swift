import Provider

private let currencyServiceType: CurrencyServiceType = 
  .currencyApiDotCom
private let currencyRateServiceType: CurrencyRateServiceType = 
  .currencyBeaconCom

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
    
    // CurrencyBeacom.com
      .register { CurrencyBeaconComEndpoints(apiKey: ApiKey.currencyBeaconCom) }
      .register { CurrencyBeaconComCurrencyService(endpoints: provider.get()) }
      .register { CurrencyBeacomComCurrencyRateService(endpoints: provider.get()) }
    
    // ExchangeRates.io
      .register { ExchangeRatesIoEndpoints(apiKey: ApiKey.exchangeRatesDotIo) }
      .register { ExchangeRatesIoCurrencyRateService(endpoints: provider.get()) }
  }
  
  private func currencyService(from provider: Provider) -> CurrencyService {
    switch currencyServiceType {
    case .currencyApiDotCom: provider.get(CurrencyApiComCurrencyService.self)
    case .currencyBeaconCom: provider.get(CurrencyBeaconComCurrencyService.self)
    }
  }
  
  private func currencyRateService(from provider: Provider) -> CurrencyRateService {
    switch currencyRateServiceType {
    case .currencyApiDotCom: provider.get(CurrencyApiComCurrencyRateService.self)
    case .currencyBeaconCom: provider.get(CurrencyBeacomComCurrencyRateService.self)
    case .exchangeRatesDotIo: provider.get(ExchangeRatesIoCurrencyRateService.self)
    }
  }
}
