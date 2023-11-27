import AppIntents
import CurrencyDomain
import Provider
import Resources

struct ConvertIntent: AppIntent {
  public static let title: LocalizedStringResource = "Convert Currency"
  
  @Parameter(title: "Amount")
  var amount: Double
  
  @Parameter(title: "From currency")
  var fromCurrency: CurrencyEntity
  
  @Parameter(title: "To currency")
  var toCurrency: CurrencyEntity
  
  func perform() async throws -> some ReturnsValue & ProvidesDialog {
    return .result(
      value: "success",
      dialog: "ok"
    )
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

public struct CurrencyQuery: EntityQuery {
  
  public init() {}
  
  public func entities(for identifiers: [String]) async throws -> [CurrencyEntity] {
    let currencyRepository: CurrencyRepository = getProvider().get()
    return await currencyRepository.getCurrencies(sorting: .favoritesFirst)
      .orThrow()
      .map { currency in
        CurrencyEntity(
          id: currency.code.id,
          name: currency.name
        )
      }
      .filter { identifiers.contains($0.id) }
  }
}
