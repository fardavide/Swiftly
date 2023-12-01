import AppIntents
import CurrencyDomain
import Provider

struct CurrencyQuery: EntityStringQuery {
  private var currencyRepository: CurrencyRepository {
    getProvider().get()
  }
  
  func entities(for identifiers: [String]) async -> [CurrencyEntity] {
    await suggestedEntities()
      .filter { identifiers.contains($0.id) }
  }
  
  func entities(matching string: String) async -> [CurrencyEntity] {
    await currencyRepository.getLatestCurrenciesWithRates(query: string, sorting: .favoritesFirst)
      .orThrow()
      .map { $0.toEntity() }
  }
  
  func suggestedEntities() async -> [CurrencyEntity] {
    await currencyRepository.getLatestCurrenciesWithRates(sorting: .favoritesFirst)
      .orThrow()
      .map { $0.toEntity() }
  }
}
