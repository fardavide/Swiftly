import AppIntents
import CurrencyDomain
import Provider
import Resources

struct ConvertIntent: AppIntent {
  static let title: LocalizedStringResource = "Convert Currency"
  static var parameterSummary: some ParameterSummary {
    Summary("Convert \(\.$amount) \(\.$fromCurrency) to \(\.$toCurrency)")
  }
  
  @Parameter(title: "Amount")
  var amount: Double
  
  @Parameter(title: "From currency")
  var fromCurrency: CurrencyEntity?
  
  @Parameter(title: "To currency")
  var toCurrency: CurrencyEntity?
  
  private var currencyQuery: CurrencyQuery {
    getProvider().get()
  }
  private var currencyRepository: CurrencyRepository {
    getProvider().get()
  }
  
  func perform() async throws -> some ProvidesDialog {
    let currencyWithRates = await currencyRepository
      .getLatestCurrenciesWithRates()
      .orThrow()
    
    let fromCurrency = try await $fromCurrency.requestDisambiguation(
      among: currencyQuery.suggestedEntities(),
      dialog: "From which currency?"
    )
    
    let toCurrency = try await $fromCurrency.requestDisambiguation(
      among: currencyQuery.suggestedEntities(),
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

extension [CurrencyWithRate] {
  func findFor(_ entity: CurrencyEntity) -> CurrencyWithRate? {
    first(where: { $0.currency.code.id == entity.id })
  }
}
