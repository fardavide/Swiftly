import AppIntents
import CurrencyDomain
import Provider

struct ConvertIntent: AppIntent {
  static let title: LocalizedStringResource = "Convert Currency"
  static var parameterSummary: some ParameterSummary {
    Summary("Convert \(\.$amount) \(\.$fromCurrency) to \(\.$toCurrency)")
  }
  
  @Parameter(title: "Amount")
  var amount: Double
  
  @Parameter(title: "From currency")
  var fromCurrency: CurrencyEntity
  
  @Parameter(title: "To currency")
  var toCurrency: CurrencyEntity
  
  private var currencyQuery: CurrencyQuery {
    getProvider().get()
  }
  private var currencyRepository: CurrencyRepository {
    getProvider().get()
  }
  
  func perform() async throws -> some ProvidesDialog {
    let fromCurrencyWithRate = fromCurrency.toDomainModel()
    let toCurrencyWithRate = toCurrency.toDomainModel()
    
    await currencyRepository.markCurrenciesUsed(
      from: fromCurrencyWithRate.currency,
      to: toCurrencyWithRate.currency
    )
    let resultValue = fromCurrencyWithRate.withValue(amount).convert(to: toCurrencyWithRate)
    return .result(dialog: "\(resultValue.value)")
  }
}
