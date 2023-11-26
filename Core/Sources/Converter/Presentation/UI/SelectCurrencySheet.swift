import CurrencyDomain
import NukeUI
import Resources
import SwiftUI

struct SelectCurrencySheet: View {
  let uiModel: SelectCurrenciesUiModel
  let actions: Actions
  
  @State private var searchQuery: String
  
  init(uiModel: SelectCurrenciesUiModel, actions: Actions) {
    self.uiModel = uiModel
    self.actions = actions
    self.searchQuery = uiModel.searchQuery
  }

  var body: some View {
    let searchQueryBinding = Binding(
      get: { searchQuery },
      set: { text in
        searchQuery = text
        actions.searchCurrencies(text)
      }
    )

    NavigationStack {
      List(uiModel.currencies, id: \.code) { currency in
        CurrencyRow(currency: currency)
          .onTapGesture { actions.selectCurrency(currency) }
      }
      .animation(.smooth, value: uiModel.currencies)
      .scrollDismissesKeyboard(.automatic)
      .navigationTitle(#string(.changeCurrency))
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(#string(.close), action: actions.dismiss)
        }
        ToolbarItem(placement: .automatic) {
          let imageKey: SfKey = switch uiModel.sorting {
          case .alphabetical: .star
          case .favoritesFirst: .starSlash
          }
          Button(
            #string(.favoritesFirst),
            systemImage: image(imageKey),
            action: { actions.setSorting(uiModel.sorting.toggle()) }
          )
        }
      }
    }
    .searchable(text: searchQueryBinding, prompt: #string(.searchCurrency))
  }

  struct Actions {
    let dismiss: () -> Void
    let selectCurrency: (Currency) -> Void
    let searchCurrencies: (_ query: String) -> Void
    let setSorting: (CurrencySorting) -> Void

    static let empty = Actions(
      dismiss: {},
      selectCurrency: { _ in },
      searchCurrencies: { _ in },
      setSorting: { _ in }
    )
  }
}

private struct CurrencyRow: View {
  let currency: Currency

  var body: some View {
    HStack {
      LazyImage(request: ImageRequest(url: currency.flagUrl))
        .processors([.resize(width: 35, unit: .pixels)])
        .frame(width: 30, height: 25)
        .clipShape(.capsule)
      #if os(macOS)
        .padding(10)
      #endif
      Text(currency.code.value)
        .font(.callout)
      Spacer()
      Text(currency.nameWithSymbol)
        .font(.callout)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(#string(.currencyWith(name: currency.name)))
  }
}

#Preview {
  SelectCurrencySheet(
    uiModel: .samples.favoritesFirst,
    actions: .empty
  )
}
