import CurrencyDomain
import DateUtils
import Foundation

struct CurrencyRatesCurrencyApiComModel: Codable, CurrencyRatesApiModel {
  let meta: Meta
  let data: [String: CurrencyRateApiModel]
  
  func toDomainModel(fallbackUpdateAt: @autoclosure () -> Date) -> CurrencyRates {
    let items = data.map { code, currencyApiModel in
      CurrencyRate(
        currencyCode: CurrencyCode(value: code),
        rate: currencyApiModel.value
      )
    }
    return CurrencyRates(
      items: items,
      updatedAt: updatedAt() ?? fallbackUpdateAt()
    )
  }
  
  func updatedAt() -> Date? {
    Date.from(meta.lastUpdatedAt, formatter: .iso8601)
  }
  
  struct Meta: Codable {
    let lastUpdatedAt: String
    
    enum CodingKeys: String, CodingKey {
      case lastUpdatedAt = "last_updated_at"
    }
  }
}
