import CurrencyDomain
import DateUtils
import Foundation

struct CurrencyRatesExchangeRatesIoModel: Codable, CurrencyRatesApiModel {
  let timestamp: Double
  let rates: [String: Double]
  
  public func toDomainModel(fallbackUpdateAt: @autoclosure () -> Date) -> CurrencyRates {
    let items = rates.map { code, rate in
      CurrencyRate(
        currencyCode: CurrencyCode(value: code),
        rate: rate
      )
    }
    return CurrencyRates(
      items: items,
      updatedAt: updatedAt()
    )
  }
  
  func updatedAt() -> Date {
    Date(timeIntervalSince1970: timestamp)
  }
}
