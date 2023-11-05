import CurrencyDomain
import DateUtils
import Foundation

public struct CurrencyRatesApiModel: Codable {
  public let meta: Meta
  public let data: [String: CurrencyRateApiModel]
  
  public struct Meta: Codable {
    public let lastUpdatedAt: String
    
    enum CodingKeys: String, CodingKey {
      case lastUpdatedAt = "last_updated_at"
    }
  }
}

public struct CurrencyRateApiModel: Codable {
  let code: String
  public let value: Double
}

public extension CurrencyRatesApiModel {
  
  static let samples = CurrencyRatesApiModelSamples()
  @available(*, deprecated, renamed: "samples.all", message: "Use samples instead")
  static let sample = CurrencyRatesApiModel(
    meta: CurrencyRatesApiModel.Meta(
      lastUpdatedAt: "now"
    ),
    data: [
      "EUR": CurrencyRateApiModel(
        code: "EUR",
        value: 0.9
      ),
      "USD": CurrencyRateApiModel(
        code: "USD",
        value: 1
      ),
    ]
  )
  
  func toDomainModels() -> [CurrencyRate] {
    self.data.map { code, currencyApiModel in
      CurrencyRate(
        currencyCode: CurrencyCode(value: code),
        rate: currencyApiModel.value
      )
    }
  }
  
  func updatedAt() -> Date? {
    Date.from(meta.lastUpdatedAt, formatter: .iso8601)
  }
}

public class CurrencyRatesApiModelSamples {
  
  public let all = CurrencyRatesApiModel(
    meta: CurrencyRatesApiModel.Meta(
      lastUpdatedAt: "2023-10-29T16:30:00+0000"
    ),
    data: [
      "EUR": CurrencyRateApiModel(
        code: "EUR",
        value: 1
      ),
      "USD": CurrencyRateApiModel(
        code: "USD",
        value: 0.7
      )
    ]
  )
  
  public let eurOnly = CurrencyRatesApiModel(
    meta: CurrencyRatesApiModel.Meta(
      lastUpdatedAt: "2023-10-29T16:30:00+0000"
    ),
    data: [
      "EUR": CurrencyRateApiModel(
        code: "EUR",
        value: 0.9
      )
    ]
  )
  
  public let usdOnly = CurrencyRatesApiModel(
    meta: CurrencyRatesApiModel.Meta(
      lastUpdatedAt: "2023-10-29T16:30:00+0000"
    ),
    data: [
      "USD": CurrencyRateApiModel(
        code: "USD",
        value: 1
      ),
    ]
  )
}
