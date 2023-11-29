import Foundation
import DateUtils

public struct CurrencyRates: Equatable {
  public let items: [CurrencyRate]
  public let updatedAt: Date
  
  public init(items: [CurrencyRate], updatedAt: Date) {
    self.items = items
    self.updatedAt = updatedAt
  }
}

public extension CurrencyRates {
  
  static let samples = CurrencyRatesSamples()
  
  func findRate(for code: CurrencyCode) -> CurrencyRate? {
    items.first(where: { $0.currencyCode == code })
  }
  
  func requireRate(for code: CurrencyCode) -> CurrencyRate {
    if let rate = findRate(for: code) {
      return rate
    } else {
      fatalError("No rate found for \(code)")
    }
  }
}

public final class CurrencyRatesSamples {
  
  public let all = CurrencyRates(
    items: CurrencyRate.samples.all(),
    updatedAt: .samples.xmas2023noon
  )
  
  public let eurOnly = CurrencyRates(
    items: [.samples.eur],
    updatedAt: .samples.xmas2023noon
  )
  
  public let usdOnly = CurrencyRates(
    items: [.samples.usd],
    updatedAt: .samples.xmas2023noon
  )
  
}
