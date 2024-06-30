import CurrencyDomain
import Design
import NukeUI
import SFSafeSymbols
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
            if let selectedCurrency = uiModel.selectedCurrency {
              send(.changeCurrency(prev: selectedCurrency, new: currency))
            } else {
              send(.addAcurrency(currency: currency))
            }
          }
      }
      .animation(.smooth, value: uiModel.currencies)
      .scrollDismissesKeyboard(.automatic)
      .navigationTitle("Change currency")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") {
            send(.closeSelectCurrency)
          }
        }
        ToolbarItem(placement: .automatic) {
          let symbol: SFSymbol = switch uiModel.sorting {
          case .alphabetical: .star
          case .favoritesFirst: .starSlash
          }
          Button {
            send(.setSorting(uiModel.sorting.toggle()))
          } label: {
            Label("Favorites first", systemSymbol: symbol)
          }
        }
      }
    }
    .searchable(text: searchQueryBinding, prompt: "Search currency")
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
    .accessibilityLabel("Currency: \(currency.name)")
  }
}

#Preview {
  SelectCurrencySheet(
    uiModel: .samples.favoritesFirst,
    send: { _ in }
  )
}
