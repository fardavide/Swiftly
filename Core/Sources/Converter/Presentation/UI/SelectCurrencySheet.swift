import CurrencyDomain
import NukeUI
import SwiftUI

struct SelectCurrencySheet: View {
  let currencies: [Currency]
  let onCurrencySelected: (Currency) -> Void
  let onSearchCurrencies: (_ query: String) -> Void
  
  @State private var searchQuery = ""
  
  var body: some View {
    let textFieldBinding = Binding(
      get: { searchQuery },
      set: { text in
        searchQuery = text
        onSearchCurrencies(text)
      }
    )

    VStack {
      TextField(
        "Search Currency",
        text: textFieldBinding
      )
      .font(.title2)
      .multilineTextAlignment(.trailing)
      List(currencies, id: \.code) { currency in
        CurrencyRow(currency: currency)
          .onTapGesture { onCurrencySelected(currency) }
      }
    }
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
            .roundedCorners(radius: 100)
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
