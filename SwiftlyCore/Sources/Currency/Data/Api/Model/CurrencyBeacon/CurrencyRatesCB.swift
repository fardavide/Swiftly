import CurrencyDomain
import Foundation

struct CurrencyRatesCurrencyBeaconComModel: Codable, CurrencyRatesApiModel {
  let response: Response
  
  func toDomainModel(fallbackUpdateAt: @autoclosure () -> Date) -> CurrencyDomain.CurrencyRates {
    let items = response.rates.map { code, rate in
      CurrencyRate(
        currencyCode: CurrencyCode(value: code),
        rate: rate
      )
    }
    return CurrencyRates(
      items: items,
      updatedAt: updatedAt() ?? fallbackUpdateAt()
    )
  }
  
  func updatedAt() -> Date? {
    Date.from(response.date, formatter: .iso8601)
  }
  
  struct Response: Codable {
    let date: String
    let rates: [String: Double]
  }
}
