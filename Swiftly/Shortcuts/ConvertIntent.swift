import AppIntents
import CurrencyDomain
import Provider
import Resources

struct ConvertIntent: AppIntent {
  public static let title: LocalizedStringResource = "Convert Currency"
  
  @Parameter(title: "Amount")
  var amount: Double
  
  @Parameter(title: "From currency")
  var fromCurrency: CurrencyEntity?
  
  @Parameter(title: "To currency")
  var toCurrency: CurrencyEntity?
  
  func perform() async throws -> some ProvidesDialog {
    let currencyRepository: CurrencyRepository = getProvider().get()
    let currencyWithRates = await currencyRepository
      .getLatestCurrenciesWithRates()
      .orThrow()
    
    let fromCurrency = try await $fromCurrency.requestDisambiguation(
      among: CurrencyQuery().suggestedEntities(),
      dialog: "From which currency?"
    )
    
    let toCurrency = try await $fromCurrency.requestDisambiguation(
      among: CurrencyQuery().suggestedEntities(),
      dialog: "To which currency?"
    )
    
    guard let fromCurrencyWithRate = currencyWithRates.findFor(fromCurrency) else {
      return .result(dialog: "Cannot get \"from currency\" rate")
    }
    guard let toCurrencyWithRate = currencyWithRates.findFor(toCurrency) else {
      return .result(dialog: "Cannot get \"to currency\" rate")
    }
    
    let resultValue = fromCurrencyWithRate.withValue(amount).convert(to: toCurrencyWithRate)
    return .result(dialog: "\(resultValue.value)")
  }
}

public struct CurrencyEntity: AppEntity {
  
  public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Currency"
  public static let defaultQuery = CurrencyQuery()
  
  public let id: String
  public let name: String
  public var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(stringLiteral: name)
  }
}

extension CurrencyWithRate {
  func toEntity() -> CurrencyEntity {
    CurrencyEntity(id: currency.code.id, name: currency.name)
  }
}

extension [CurrencyWithRate] {
  func findFor(_ entity: CurrencyEntity) -> CurrencyWithRate? {
    first(where: { $0.currency.code.id == entity.id })
  }
}

public struct CurrencyQuery: EntityQuery {
  
  public init() {}
  
  public func entities(for identifiers: [String]) async -> [CurrencyEntity] {
    await suggestedEntities()
      .filter { identifiers.contains($0.id) }
  }
  
  public func suggestedEntities() async -> [CurrencyEntity] {
    let currencyRepository: CurrencyRepository = getProvider().get()
    return await currencyRepository.getCurrencies(sorting: .favoritesFirst)
      .orThrow()
      .map { currency in
        CurrencyEntity(
          id: currency.code.id,
          name: currency.name
        )
      }
  }
}
