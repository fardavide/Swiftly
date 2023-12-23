import CurrencyDomain
import Design
import NukeUI
import Resources
import SwiftUI

struct SelectCurrencySheet: View {
  let uiModel: SelectCurrenciesUiModel
  let send: (ConverterAction) -> Void

  @State private var searchQuery: String
  
  init(
    uiModel: SelectCurrenciesUiModel,
    send: @escaping (ConverterAction) -> Void
  ) {
    self.uiModel = uiModel
    self.send = send
    self.searchQuery = uiModel.searchQuery
  }

  var body: some View {
    let searchQueryBinding = Binding(
      get: { searchQuery },
      set: { text in
        searchQuery = text
        send(.searchCurrencies(query: text))
      }
    )

    NavigationStack {
      List(uiModel.currencies, id: \.code) { currency in
        CurrencyRow(currency: currency)
          .onTapGesture {
            send(.changeCurrency(prev: uiModel.selectedCurrency, new: currency))
          }
      }
      .animation(.smooth, value: uiModel.currencies)
      .scrollDismissesKeyboard(.automatic)
      .navigationTitle(#string(.changeCurrency))
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(#string(.close)) {
            send(.closeSelectCurrency)
          }
        }
        ToolbarItem(placement: .automatic) {
          let imageKey: SfKey = switch uiModel.sorting {
          case .alphabetical: .star
          case .favoritesFirst: .starSlash
          }
          Button(
            #string(.favoritesFirst),
            systemImage: image(imageKey),
            action: { send(.setSorting(uiModel.sorting.toggle())) }
          )
        }
      }
    }
    .searchable(text: searchQueryBinding, prompt: #string(.searchCurrency))
  }
}

private struct CurrencyRow: View {
  let currency: Currency

  var body: some View {
    HStack {
      CurrencyFlagImage(for: currency, size: .small)
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
    send: { _ in }
  )
}
