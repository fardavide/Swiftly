import AppIntents
import CurrencyDomain
import Provider

struct CurrencyQuery: EntityQuery {
  private var currencyRepository: CurrencyRepository {
    getProvider().get()
  }
  
  func entities(for identifiers: [String]) async -> [CurrencyEntity] {
    await suggestedEntities()
      .filter { identifiers.contains($0.id) }
  }
  
  func suggestedEntities() async -> [CurrencyEntity] {
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
