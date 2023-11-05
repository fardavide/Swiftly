import CurrencyDomain
import NukeUI
import SwiftUI

struct SelectCurrencySheet: View {
  let currencies: [Currency]
  let onCurrencySelected: (Currency) -> Void
  let onSearchCurrencies: (_ query: String) -> Void
  
  @State private var searchQuery = ""
  
  var body: some View {
    let searchQueryBinding = Binding(
      get: { searchQuery },
      set: { text in
        searchQuery = text
        onSearchCurrencies(text)
      }
    )

    NavigationStack {
      List(currencies, id: \.code) { currency in
        CurrencyRow(currency: currency)
          .onTapGesture { onCurrencySelected(currency) }
      }
      .scrollDismissesKeyboard(.automatic)
      .navigationTitle("Change currency")
    }
    .searchable(text: searchQueryBinding, prompt: "Search Currency")
  }
}

private struct CurrencyRow: View {
  let currency: Currency
  
  var body: some View {
    HStack {
      LazyImage(
        request: ImageRequest(
          url: currency.flagUrl,
          processors: [
            .resize(height: 20),
            .circle(border: .none)
          ]
        )
      )
      .frame(width: 32, height: 20)
      .clipShape(.circle)
      Text(currency.code.value)
      Spacer()
      Text(currency.nameWithSymbol)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Currency: \(currency.name)")
  }
}

#Preview {
  SelectCurrencySheet(
    currencies: Currency.samples.all(),
    onCurrencySelected: { _ in },
    onSearchCurrencies: { _ in }
  )
}
