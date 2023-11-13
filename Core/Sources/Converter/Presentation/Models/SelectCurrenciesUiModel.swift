import CurrencyDomain

struct SelectCurrenciesUiModel {
  let currencies: [Currency]
  let sorting: CurrencySorting
}

extension SelectCurrenciesUiModel {
  static let samples = SelectCurrenciesUiModelSamples()
}

class SelectCurrenciesUiModelSamples {
  
  let alphabetical = SelectCurrenciesUiModel(
    currencies: Currency.samples.all(),
    sorting: .alphabetical
  )
  
  let favoritesFirst = SelectCurrenciesUiModel(
    currencies: [
      .samples.eur,
      .samples.usd,
      .samples.cny,
      .samples.chf,
      .samples.gbp,
      .samples.jpy
    ],
    sorting: .favoritesFirst
  )
}
